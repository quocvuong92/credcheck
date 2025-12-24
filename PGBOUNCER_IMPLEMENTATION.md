# PgBouncer Support Implementation Guide

## Overview

Version 4.3.0 adds support for tracking authentication failures through PgBouncer.

## New Functions

| Function | Purpose |
|----------|---------|
| `pg_auth_attempt_begin(username)` | Track auth attempts, detect failures |
| `pg_auth_attempt_success(username)` | Clear pending auth on successful login |
| `pg_check_user_banned(username)` | Check if user is banned |

## Implementation Steps

### Step 1: Update Extension

```sql
ALTER EXTENSION credcheck UPDATE TO '4.3.0';
```

### Step 2: Deploy user_search Function

```sql
CREATE OR REPLACE FUNCTION public.user_search(uname text)
RETURNS TABLE(usename name, passwd text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_allowed BOOLEAN;
BEGIN
    BEGIN
        SELECT pg_auth_attempt_begin(uname::name) INTO v_allowed;
        IF NOT v_allowed THEN
            RETURN;
        END IF;
    EXCEPTION WHEN undefined_function THEN
        NULL;
    END;

    RETURN QUERY
    SELECT s.usename, s.passwd 
    FROM pg_catalog.pg_shadow s 
    WHERE s.usename = uname;
END;
$function$;

GRANT EXECUTE ON FUNCTION public.user_search(text) TO cnpg_pooler_pgbouncer;
```

### Step 3: Configure Settings

```sql
ALTER SYSTEM SET credcheck.max_auth_failure = 5;
SELECT pg_reload_conf();
```

## Monitoring

```sql
-- View banned users
SELECT * FROM pg_banned_role;

-- Unban a user
SELECT pg_banned_role_reset('username');
```

## Testing

```bash
# Wrong password multiple times (wait 5+ seconds between attempts)
PGPASSWORD=wrong psql -h <pgbouncer-host> -U testuser -d postgres

# Check banned status
psql -c "SELECT * FROM pg_banned_role;"
```
