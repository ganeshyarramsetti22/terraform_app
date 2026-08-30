const express = require("express");
const sql = require("mssql");
const { DefaultAzureCredential } = require("@azure/identity");

const app = express();

const PORT = process.env.PORT || 3000;

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

const credential = new DefaultAzureCredential();

async function getSqlPool() {
  const token = await credential.getToken(
    "https://database.windows.net/.default"
  );

  const config = {
    server: process.env.SQL_SERVER_NAME,
    database: process.env.SQL_DATABASE_NAME,
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

  return sql.connect(config);
}

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
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
      );
    END
  `);

  console.log("Database initialized successfully.");
}

app.get("/health", async (req, res) => {
  try {
    const pool = await getSqlPool();

    await pool.request().query("SELECT 1 AS healthy");

    res.status(200).json({
      status: "healthy",
      database: "connected"
    });
  } catch (error) {
    console.error("Health check failed:", error.message);

    res.status(500).json({
      status: "unhealthy",
      database: "disconnected"
    });
  }
});

app.get("/", async (req, res) => {
  try {
    const pool = await getSqlPool();

    const result = await pool.request().query(`
      SELECT id, name, email, created_at
      FROM users
      ORDER BY id DESC
    `);

    const rows = result.recordset
      .map(
        (user) => `
          <tr>
            <td>${user.id}</td>
            <td>${user.name}</td>
            <td>${user.email}</td>
            <td>${user.created_at}</td>
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

          th, td {
            border: 1px solid #ccc;
            padding: 10px;
          }

          th {
            background: #f2f2f2;
          }
        </style>
      </head>

      <body>
        <h1>Simple User Application</h1>

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

        <h2>Users</h2>

        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Email</th>
              <th>Created At</th>
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
    console.error("Application error:", error.message);

    res.status(500).send(`
      <h1>Application Error</h1>
      <p>Unable to connect to the database.</p>
    `);
  }
});

app.post("/users", async (req, res) => {
  try {
    const { name, email } = req.body;

    if (!name || !email) {
      return res.status(400).json({
        error: "Name and email are required"
      });
    }

    const pool = await getSqlPool();

    await pool
      .request()
      .input("name", sql.NVarChar(100), name)
      .input("email", sql.NVarChar(255), email)
      .query(`
        INSERT INTO users (name, email)
        VALUES (@name, @email)
      `);

    res.redirect("/");
  } catch (error) {
    console.error("Insert failed:", error.message);

    res.status(500).json({
      error: "Unable to save user"
    });
  }
});

async function start() {
  try {
    await initializeDatabase();

    app.listen(PORT, () => {
      console.log(`Simple User App listening on port ${PORT}`);
    });
  } catch (error) {
    console.error("Application startup failed:", error.message);
    process.exit(1);
  }
}

start();

module.exports = app;