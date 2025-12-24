-- credcheck extension update for PgBouncer support
-- Version 4.2.0 to 4.3.0
-- Copyright (c) 2024-2025 HexaCluster Corp

----
-- Mark the beginning of an authentication attempt.
-- Called by user_search() when PgBouncer requests credentials.
-- Also detects expired pending auth from previous attempts (= failures).
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
-- If no username provided, uses current_user.
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
-- Lightweight check for use in user_search().
----
CREATE FUNCTION pg_check_user_banned(IN username name)
RETURNS boolean
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT VOLATILE;

GRANT EXECUTE ON FUNCTION pg_check_user_banned(name) TO PUBLIC;
