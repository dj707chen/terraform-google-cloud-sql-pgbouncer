# My Notes

    psql $(terraform output -json | jq -r '.database_url.value')
            psql (14.8 (Homebrew), server 12.16)
            Type "help" for help.
    
    terraform output -json | jq -r '.database_url.value'
            postgres://antslift-user:aPass@34.69.30.96:25128/antslift_db

    psql postgres://postgres:aPass@34.69.30.96:25128/antslift_db
