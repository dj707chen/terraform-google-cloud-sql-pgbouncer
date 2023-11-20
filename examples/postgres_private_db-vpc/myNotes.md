# My Notes

## How PgBouncer is started
Running this Docker image: https://hub.docker.com/r/edoburu/pgbouncer/

## Connection
    psql $(terraform output -json | jq -r '.database_url.value')
            psql (14.8 (Homebrew), server 12.16)
            Type "help" for help.
    
    terraform output -json | jq -r '.database_url.value'
            postgres://antslift-user:aPass@34.171.210.15:6432/antslift_db

    psql postgres://postgres:aPass@34.171.210.15:6432/antslift_db

## Timeout connect to PgBouncer
    # SSH into PgBouncer VM
    docker ps
        CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS                                                     NAMES
        11d11d8237b3   edoburu/pgbouncer:latest   "/entrypoint.sh /usr…"   7 seconds ago   Up 4 seconds   5432/tcp, 0.0.0.0:25128->25128/tcp, :::25128->25128/tcp   pgbouncer

    # If pgbouncer docker container is not running, restart
    sudo systemctl restart pgbouncer
    sudo systemctl edit pgbouncer

## Connect from within PgBouncer VM
    # SSH into PgBouncer VM
    toolbox

    # List listening ports
    sudo lsof -nP -iTCP -sTCP:LISTEN

    apt-get update
    apt-get install postgresql-client

    psql postgres://antslift-user@34.171.210.15:6432/antslift_db
    psql --username=antslift-user -h 34.171.210.15 -p 6432 antslift_db

    # Connect to Cloud PG private IP
    psql --username=antslift-user -h 172.24.0.3 -p 5432 antslift_db
