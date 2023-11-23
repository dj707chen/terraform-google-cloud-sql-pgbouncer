# My Notes

## How PgBouncer is started
Running this Docker image: https://hub.docker.com/r/edoburu/pgbouncer/

## Connection
    gcloud sql connect db-1e2ed67dc3 \
        --project=lunar-outlet-403221
    #   --region=us-central1

    terraform output
instance_name="vm-pgbouncer-1e2ed67dc3"
port=6432
private_ip_address="10.128.0.7"
ps_name="google-managed-services-db-vpc"
public_ip_address="104.154.138.162"

    DATABASE_URL=postgres://antslift-user:aPass@${public_ip_address}:6432/antslift_db
    TM_DATABASE_URL=$(terraform output -json | jq -r '.database_url.value')
    echo ${TM_DATABASE_URL}
    echo ${DATABASE_URL}

    psql ${DATABASE_URL}


## Useful commands
    docker logs pgbouncer
    docker exec pgbouncer sh

    # If pgbouncer docker container is not running, restart
    sudo systemctl restart pgbouncer
    sudo systemctl edit pgbouncer

    docker stop pgbouncer
    docker rm   pgbouncer
    docker run \
        --name pgbouncer \
        --restart always \
        -p 6432:6432 \
        -v /run/user/userlist.txt:/etc/pgbouncer/userlist.txt:ro \
        -v /run/user/pgbouncer.ini:/etc/pgbouncer/pgbouncer.ini:ro \
        edoburu/pgbouncer

## Install PgBouncer SQL
Source: https://github.com/CrunchyData/crunchy-containers/blob/REL_4_7/bin/postgres-ha/sql/pgbouncer/pgbouncer-install.sql?CrunchyAnonId=hilmdqygnmlohafnvolopjjqffkbiffucdskiepahx

This solution does not require that user `pgbouncer` to be SUPERUSER, this is different from [README.md](..%2F3-query-users%2FREADME.md)

PgBouncer SQL needs to be installed in every DB:

    DB_PUBLIC_IP=34.173.8.16
    psql postgres://postgres:aPass@${DB_PUBLIC_IP}:5432/postgres    -f pgbouncer-install.sql
    psql postgres://postgres:aPass@${DB_PUBLIC_IP}:5432/antslift_db -f pgbouncer-install.sql

Verify if the function is created:

    SET search_path TO pgbouncer, public;
    show search_path;
            search_path
            -------------
            pgbouncer, public
            (1 row)
    
    \df
            List of functions
            Schema   |   Name   |          Result data type           | Argument data types | Type
            -----------+----------+-------------------------------------+---------------------+------
            pgbouncer | get_auth | TABLE(username text, password text) | username text       | func
            (1 row)

    SELECT username, password from pgbouncer.get_auth('user1');
            username |              password
            ----------+-------------------------------------
            user1    | md57d1b5a4329b6478e976508ab9a49ee3d
            (1 row)

## Connect from within PgBouncer VM
    # SSH into PgBouncer VM
    toolbox

    # List listening ports
    sudo lsof -nP -iTCP -sTCP:LISTEN

    apt-get update
    apt-get install postgresql-client

    psql postgres://antslift-user@104.154.138.162:6432/antslift_db
    psql --username=antslift-user -h 104.154.138.162 -p 6432 antslift_db

    # Connect to Cloud PG private IP
    psql --username=antslift-user -h 172.24.0.3 -p 5432 antslift_db

## Issue
    2023-11-21 05:08:34.863 UTC [1] LOG C-0x7f80e56b33b0: antslift_db/antslift-user@69.174.173.95:35694 login attempt: db=antslift_db user=antslift-user tls=no
    2023-11-21 05:08:34.925 UTC [1] LOG S-0x7f80e563f590: antslift_db/antslift-user@10.77.0.3:5432 new connection to server (from 172.17.0.2:52454)
    2023-11-21 05:08:34.933 UTC [1] LOG S-0x7f80e563f590: antslift_db/antslift-user@10.77.0.3:5432 SSL established: TLSv1.3/TLS_AES_256_GCM_SHA384/ECDH=prime256v1
    2023-11-21 05:08:34.935 UTC [1] ERROR S-0x7f80e563f590: antslift_db/antslift-user@10.77.0.3:5432 cannot do SCRAM authentication: wrong password type
    2023-11-21 05:08:34.935 UTC [1] LOG C-0x7f80e56b33b0: antslift_db/antslift-user@69.174.173.95:35694 closing because: server login failed: wrong password type (age=0s)
    2023-11-21 05:08:34.935 UTC [1] WARNING C-0x7f80e56b33b0: antslift_db/antslift-user@69.174.173.95:35694 pooler error: server login failed: wrong password type
    2023-11-21 05:08:34.935 UTC [1] LOG S-0x7f80e563f590: antslift_db/antslift-user@10.77.0.3:5432 closing because: failed to answer authreq (age=0s)
