const express = require("express");
const sql = require("mssql");
const { DefaultAzureCredential } = require("@azure/identity");

const app = express();


// ============================================================
// APPLICATION CONFIGURATION
// ============================================================

const PORT = process.env.PORT || 3000;


// ============================================================
// AZURE SQL CONFIGURATION
// ============================================================
//
// These values come from Azure App Service Application Settings:
//
// SQL_SERVER_NAME
// SQL_DATABASE_NAME
//
// Local development:
//   az login
//   DefaultAzureCredential uses your Azure identity.
//
// Azure App Service:
//   DefaultAzureCredential uses the System Assigned
//   Managed Identity.
//
// No SQL username or password is stored in this application.
// ============================================================

const SQL_SERVER = process.env.SQL_SERVER_NAME;
const SQL_DATABASE = process.env.SQL_DATABASE_NAME;

if (!SQL_SERVER || !SQL_DATABASE) {
  throw new Error(
    "SQL_SERVER_NAME and SQL_DATABASE_NAME environment variables are required."
  );
}

const credential = new DefaultAzureCredential();


// ============================================================
// EXPRESS CONFIGURATION
// ============================================================

app.use(express.urlencoded({ extended: true }));
app.use(express.json());


// ============================================================
// SQL CONNECTION POOL
// ============================================================
//
// We keep one connection pool and reuse it instead of creating
// a new connection for every request.
// ============================================================

let sqlPool = null;

async function getSqlPool() {

  // Return existing pool if already connected

  if (sqlPool && sqlPool.connected) {
    return sqlPool;
  }


  // Get Azure SQL access token

  const token = await credential.getToken(
    "https://database.windows.net/.default"
  );


  if (!token || !token.token) {
    throw new Error(
      "Unable to obtain Azure SQL access token."
    );
  }


  // Azure SQL configuration

  const dbConfig = {

    server: SQL_SERVER,

    port: 1433,

    database: SQL_DATABASE,

    options: {
      encrypt: true,
      trustServerCertificate: false
    },

    authentication: {
      type: "azure-active-directory-access-token",

      options: {
        token: token.token
      }
    }
  };


  // Create connection pool

  sqlPool = await sql.connect(dbConfig);

  console.log(
    "Connected to Azure SQL Database successfully."
  );

  return sqlPool;
}


// ============================================================
// DATABASE INITIALIZATION
// ============================================================

async function initializeDatabase() {

  const pool = await getSqlPool();


  await pool.request().query(`
    IF NOT EXISTS (
      SELECT 1
      FROM sys.tables
      WHERE name = 'users'
    )
    BEGIN

      CREATE TABLE users (

        id INT IDENTITY(1,1) PRIMARY KEY,

        name NVARCHAR(100) NOT NULL,

        email NVARCHAR(255) NOT NULL,

        created_at DATETIME2 NOT NULL
          DEFAULT SYSUTCDATETIME()

      );

    END
  `);


  console.log(
    "Database initialized successfully."
  );
}


// ============================================================
// HEALTH CHECK
// ============================================================

app.get("/health", async (req, res) => {

  try {

    const pool = await getSqlPool();


    await pool
      .request()
      .query("SELECT 1 AS healthy");


    res.status(200).json({

      status: "healthy",

      database: "connected"

    });

  } catch (error) {

    console.error(
      "Health check database error:",
      error.message
    );


    res.status(500).json({

      status: "unhealthy",

      database: "disconnected"

    });

  }

});


// ============================================================
// HOME PAGE
// ============================================================

app.get("/", async (req, res) => {

  try {

    const pool = await getSqlPool();


    const result = await pool
      .request()
      .query(`
        SELECT
          id,
          name,
          email,
          created_at
        FROM users
        ORDER BY id DESC
      `);


    const rows = result.recordset
      .map(
        (user) => `

          <tr>

            <td>
              ${user.id}
            </td>

            <td>
              ${user.name}
            </td>

            <td>
              ${user.email}
            </td>

            <td>
              ${user.created_at}
            </td>

          </tr>

        `
      )
      .join("");


    res.send(`

      <!DOCTYPE html>

      <html>

      <head>

        <title>Simple User App</title>

        <style>

          body {

            font-family: Arial, sans-serif;

            max-width: 900px;

            margin: 40px auto;

            padding: 20px;

          }


          h1 {

            margin-bottom: 30px;

          }


          input {

            padding: 10px;

            margin: 5px;

          }


          button {

            padding: 10px 20px;

            cursor: pointer;

          }


          table {

            width: 100%;

            margin-top: 30px;

            border-collapse: collapse;

          }


          th,
          td {

            border: 1px solid #ccc;

            padding: 10px;

            text-align: left;

          }


          th {

            background: #f2f2f2;

          }

        </style>

      </head>


      <body>

        <h1>
          Simple User Application
        </h1>


        <form method="POST" action="/users">

          <input
            type="text"
            name="name"
            placeholder="Name"
            required
          />


          <input
            type="email"
            name="email"
            placeholder="Email"
            required
          />


          <button type="submit">
            Add User
          </button>

        </form>


        <h2>
          Users
        </h2>


        <table>

          <thead>

            <tr>

              <th>
                ID
              </th>

              <th>
                Name
              </th>

              <th>
                Email
              </th>

              <th>
                Created At
              </th>

            </tr>

          </thead>


          <tbody>

            ${rows}

          </tbody>

        </table>


      </body>

      </html>

    `);

  } catch (error) {

    console.error(
      "Application error:",
      error.message
    );


    res.status(500).send(`

      <h1>
        Application Error
      </h1>

      <p>
        Unable to connect to Azure SQL Database.
      </p>

    `);

  }

});


// ============================================================
// CREATE USER
// ============================================================

app.post("/users", async (req, res) => {

  try {

    const { name, email } = req.body;


    // --------------------------------------------------------
    // Validate input
    // --------------------------------------------------------

    if (!name || !email) {

      return res.status(400).json({

        error:
          "Name and email are required"

      });

    }


    // --------------------------------------------------------
    // Get Azure SQL connection
    // --------------------------------------------------------

    const pool = await getSqlPool();


    // --------------------------------------------------------
    // Insert user
    // --------------------------------------------------------
    //
    // Parameterized query prevents SQL injection.
    // --------------------------------------------------------

    await pool

      .request()

      .input(
        "name",
        sql.NVarChar(100),
        name
      )

      .input(
        "email",
        sql.NVarChar(255),
        email
      )

      .query(`

        INSERT INTO users (

          name,

          email

        )

        VALUES (

          @name,

          @email

        )

      `);


    console.log(
      `User created successfully: ${name} - ${email}`
    );


    // --------------------------------------------------------
    // Return to home page
    // --------------------------------------------------------

    res.redirect("/");

  } catch (error) {

    console.error(
      "Insert failed:",
      error.message
    );


    res.status(500).json({

      error:
        "Unable to save user",

      details:
        error.message

    });

  }

});


// ============================================================
// START APPLICATION
// ============================================================

async function start() {

  // ----------------------------------------------------------
  // Start web server first
  // ----------------------------------------------------------

  app.listen(PORT, () => {

    console.log(
      `Simple User App listening on port ${PORT}`
    );

    console.log(
      `Azure SQL Server: ${SQL_SERVER}`
    );

    console.log(
      `Azure SQL Database: ${SQL_DATABASE}`
    );

  });


  // ----------------------------------------------------------
  // Initialize database
  // ----------------------------------------------------------

  try {

    await initializeDatabase();

  } catch (error) {

    console.error(
      "Database initialization failed:",
      error.message
    );

    console.error(
      "Application is still running, but database initialization failed."
    );

  }

}


// ============================================================
// START APPLICATION
// ============================================================

start();


// ============================================================
// EXPORT APPLICATION
// ============================================================

module.exports = app;