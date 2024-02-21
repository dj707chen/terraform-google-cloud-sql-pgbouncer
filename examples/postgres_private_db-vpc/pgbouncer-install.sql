-- pgbouncer-install.sql creates the general infrastructure for using pgBouncer with the PostgreSQL Operator
-- This is intended to be executed in the "template1" file as well as any database that exists at the time this script is being executed.

-- First, check that there is a "pgbouncer" administrative user
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pgbouncer') THEN
        CREATE ROLE pgbouncer LOGIN PASSWORD 'pgbouncer';
        -- SELECT * FROM pg_roles where rolname = 'pgbouncer';
    END IF;
END
$$;

REVOKE ALL PRIVILEGES ON SCHEMA public FROM pgbouncer;

-- All of the administrative functions for pgbouncer will live in its own
-- schema, conveniently titled "pgbouncer"
CREATE SCHEMA IF NOT EXISTS pgbouncer;

-- ...but even though pgbouncer gets its own schema, lock down what it can do on it
REVOKE ALL PRIVILEGES ON SCHEMA pgbouncer FROM pgbouncer;
GRANT USAGE ON SCHEMA pgbouncer TO pgbouncer;

CREATE OR REPLACE FUNCTION pgbouncer.get_auth(username TEXT)
RETURNS TABLE(username TEXT, password TEXT) AS
$$
  SELECT rolname::TEXT, rolpassword::TEXT
  FROM pg_authid
  WHERE
    NOT pg_authid.rolreplication AND
    pg_authid.rolcanlogin AND
    pg_authid.rolname <> 'pgbouncer' AND (
      pg_authid.rolvaliduntil IS NULL OR
      pg_authid.rolvaliduntil >= CURRENT_TIMESTAMP
    ) AND
    pg_authid.rolname = $1;
$$
LANGUAGE SQL STABLE SECURITY DEFINER;

-- As mentioned, the pgbouncer user will only be able to access its one function and all it can do is execute.
REVOKE ALL ON FUNCTION pgbouncer.get_auth(username TEXT) FROM PUBLIC, pgbouncer;
GRANT EXECUTE ON FUNCTION pgbouncer.get_auth(username TEXT) TO pgbouncer;
