# Postgres + PgAdmin + Pagila Example

This project provides a ready-to-use Docker Compose setup for running a PostgreSQL database with the [Pagila sample database](https://github.com/devrimgunduz/pagila) and PgAdmin for database management.

## Project Structure

- `docker-compose.yml` – Docker Compose configuration for PostgreSQL and PgAdmin.
- `init-db/` – Place the Pagila database SQL files here to initialize the database.
- `queries/queries..sql` – Example SQL queries for analytics and reporting.

## Getting Started

### 1. Clone this repository

```sh
git clone <your-repo-url>
cd <your-repo-directory>
```

### 2. Download the Pagila Database

Clone or download the Pagila database SQL files from [https://github.com/devrimgunduz/pagila](https://github.com/devrimgunduz/pagila).

Copy the SQL files (typically `pagila-schema.sql` and `pagila-data.sql`) into the `init-db/` directory.

### 3. Start the Services

```sh
docker-compose up
```

- PostgreSQL will be available on port `5432`.
- PgAdmin will be available at [http://localhost:5050](http://localhost:5050).

### 4. Access PgAdmin

- Open [http://localhost:5050](http://localhost:5050) in your browser.
- Login with:
  - **Email:** `admin@local.dev`
  - **Password:** `admin123`
- Add a new server in PgAdmin:
  - **Host:** `postgres`
  - **Port:** `5432`
  - **Username:** `postgres`
  - **Password:** `secret`
  - **Database:** `pagila`

### 5. Run Example Queries

You can find example queries in [`queries/queries..sql`](queries/queries..sql). Use PgAdmin or any SQL client to run these queries against the `pagila` database.

## Notes

- The database will be initialized automatically on first run using the SQL files in `init-db/`.
- Make sure Docker is installed and running on your machine.

## License

This project is for educational/demo purposes.