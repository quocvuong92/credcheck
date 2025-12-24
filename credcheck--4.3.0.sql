-- credcheck extension for PostgreSQL
-- Copyright (c) 2021-2023 MigOps Inc
-- Copyright (c) 2023 Gilles Darold
-- Copyright (c) 2024-2025 HexaCluster Corp

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION credcheck" to load this file. \quit

----
-- Remove all entries from password history.
-- Returns the number of entries removed.
----
CREATE FUNCTION pg_password_history_reset( )
RETURNS integer
AS 'MODULE_PATHNAME'
LANGUAGE C VOLATILE;

----
-- Remove entries of the specified user from password history.
-- Returns the number of entries removed.
----
CREATE FUNCTION pg_password_history_reset( IN username name )
RETURNS integer
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT VOLATILE;

----
-- Look at password history entries
----
CREATE FUNCTION pg_password_history (
	OUT rolename name,
	OUT password_date timestamp with time zone,
	OUT password_hash text
)
RETURNS SETOF record
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT VOLATILE;

-- Register a view on the function for ease of use.
CREATE VIEW pg_password_history AS
  SELECT * FROM pg_password_history();

----
-- Change password creation timestamp for all entries of the specified
-- user in the password history. Proposed for testing purpose only.
-- Returns the number of entries changed.
----
CREATE FUNCTION pg_password_history_timestamp( IN username name, IN new_timestamp timestamp with time zone)
RETURNS integer
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT VOLATILE;

GRANT SELECT ON pg_password_history TO PUBLIC;

-- Don't want this to be available to non-superusers.
REVOKE ALL ON FUNCTION pg_password_history_reset() FROM PUBLIC;
REVOKE ALL ON FUNCTION pg_password_history_reset(name) FROM PUBLIC;
REVOKE ALL ON FUNCTION pg_password_history_timestamp(name, timestamp with time zone) FROM PUBLIC;

----
-- Remove all entries from authent failure cache.
-- Returns the number of entries removed.
----
CREATE FUNCTION pg_banned_role_reset( )
RETURNS integer
AS 'MODULE_PATHNAME'
LANGUAGE C VOLATILE;

----
-- Remove entries of the specified user from authent failure cache.
-- Returns the number of entries removed.
----
CREATE FUNCTION pg_banned_role_reset( IN username name )
RETURNS integer
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT VOLATILE;

----
-- Look at authent failure cache entries
----
CREATE FUNCTION pg_banned_role (
	OUT roleid Oid,
	OUT failure_count integer,
	OUT banned_date timestamp
)
RETURNS SETOF record
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT VOLATILE;

-- Register a view on the function for ease of use.
CREATE VIEW pg_banned_role AS
  SELECT roleid::regrole, failure_count, banned_date FROM pg_banned_role();

GRANT SELECT ON pg_banned_role TO PUBLIC;

-- Don't want this to be available to non-superusers.
REVOKE ALL ON FUNCTION pg_banned_role_reset() FROM PUBLIC;
REVOKE ALL ON FUNCTION pg_banned_role_reset(name) FROM PUBLIC;

----
-- PgBouncer Support Functions (v4.3.0)
----

----
-- Mark the beginning of an authentication attempt.
-- Called by user_search() when PgBouncer requests credentials.
-- Returns FALSE if user is banned or doesn't exist, TRUE otherwise.
----
CREATE FUNCTION pg_auth_attempt_begin(IN username name)
RETURNS boolean
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT VOLATILE;

GRANT EXECUTE ON FUNCTION pg_auth_attempt_begin(name) TO PUBLIC;

----
-- Mark a successful authentication (clears pending auth).
-- Should be called when a user successfully connects.
----
CREATE FUNCTION pg_auth_attempt_success()
RETURNS boolean
AS 'MODULE_PATHNAME'
LANGUAGE C VOLATILE;

CREATE FUNCTION pg_auth_attempt_success(IN username name)
RETURNS boolean
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT VOLATILE;

GRANT EXECUTE ON FUNCTION pg_auth_attempt_success() TO PUBLIC;
GRANT EXECUTE ON FUNCTION pg_auth_attempt_success(name) TO PUBLIC;

----
-- Check if a user is currently banned.
----
CREATE FUNCTION pg_check_user_banned(IN username name)
RETURNS boolean
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT VOLATILE;

GRANT EXECUTE ON FUNCTION pg_check_user_banned(name) TO PUBLIC;
