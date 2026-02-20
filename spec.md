Create a flutter app called LiveEvents, where it will show all events around a location (either GPS or chosen location by a pin). Events feed: Anyone can submit events, also source events from other sources to merge to the feed. Either guest mode or login with OneID authentication system (will give details). Events can be submitted by anyone but will be offered to create account / login after submission. .... List about 50 user flows for the app, real usage user flows not technical user flows. 
....

Use the VisionOS Glass / MEOS theme as in /Users/thanhson/Workspace/abn.meos.app.1

Use the skills from here: 
ABN Skills

Use the skills at 
/Users/thanhson/Workspace/abn.skills


Skills repo by Claude
https://github.com/stevennt/abn.ai.skills

Prompt:

… Use the skills at /Users/thanhson/Workspace/abn.ai.skills

/Users/thanhson/Workspace/abn.ai.skills


Visit all pages and improve using the skills at /Users/thanhson/Workspace/abn.ai.skills

Visit all pages and design the theme using the skills at /Users/thanhson/Workspace/abn.ai.skills




AXUM API SERVER


TASK
AXUM API Server
PATH
/Users/thanhson/Workspace/abn.apiserver.rust.axum
SKILL
/Users/thanhson/Workspace/abn.apiserver.rust.axum/skills/abn-axum-api-server/SKILL.md
LOCAL
/Users/thanhson/Workspace/abn.apiserver.rust.axum
docker compose -f docker-compose.local.yml build
docker compose -f docker-compose.local.yml up

For development, you can start the local docker if not yet started, develop and use the API-s here. You can ask me to deploy to production (axum.abnasia.org) if needed. The final app always need to work with axum.abnasia.org but during development you can use the development API server.


PRODUCTION
axum.abnasia.org
NOTES





TASK
PYTHON Environment


source ~/Downloads/abnvirtualenv/bin/activate





POSTGRESQL Schema



TASK
POSTGRESQL Schema


/Users/thanhson/Workspace/abn.postgresql/scripts/docs/full_schema_dump.sql

How to create / refresh this? 
cd /Users/thanhson/Workspace/abn.postgresql/scripts/

python3 manage.py schema fetch prod --output docs/full_schema_dump.sql

OR Manually:
python3 manage.py
Choose 1. Schema Management
Choose 1. Fetch Schema (Prod)










NOTES










TASK
POSTGRESQL LOGIN
User
abn.demo.1
thanhson
Agent User
Agent/Service Name: ABN Agent 1
✅ Agent Created: yk7erfgywmky
🔑 API KEY: ak_8edeaacb2e62438ab325b7980f8f6788
⚠️  Store this key safely! It will not be shown again (only hash is stored).


POSTREST
-**JWTSecret**: `7kQ9mN2pL4xR8vT6yW3zB5nM7jK9sD4fG8hL2qX6cV9bN3mP5rT8wY4zA7eR2uJ6`



/opt/homebrew/opt/libpq/bin/psql "postgres://postgres:cV26LUnDhQBb@bouncer.abnasia.org/abnasia_db?sslmode=require"

# PostgREST Connection Details

**Status**: ✅ Connected Successfully
**URL**: `https://pgapi.abnasia.org`





# PostgREST Connection Details

**Status**: ✅ Connected Successfully
**URL**: `https://pgapi.abnasia.org`

## Overview
The PostgREST service is functioning and accessible via HTTPS.
It is currently configured for **public, anonymous access** with **superuser privileges**.

## Connection Details
- **Base URL**: `https://pgapi.abnasia.org`
- **Authentication**: 
    - **Anonymous**: Enabled (Currently has full admin access).
    - **JWT**: 
- **JWT Secret**: `7kQ9mN2pL4xR8vT6yW3zB5nM7jK9sD4fG8hL2qX6cV9bN3mP5rT8wY4zA7eR2uJ6`
- **SSL/TLS**: Valid HTTPS certificate (Let's Encrypt).



NOTES








