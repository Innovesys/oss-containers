# Ensure PGDATA directory exists and has correct permissions
Write-Host "Ensuring PGDATA directory permissions..."
New-Item -Path $env:PGDATA -ItemType Directory -Force | Out-Null
icacls $env:PGDATA /grant "${env:USERNAME}:(OI)(CI)F" | Out-Null

# Initialize database if it's uninitialized
if (-not (Test-Path -Path "$env:PGDATA\PG_VERSION")) {
    # Set default values for environment variables
    if (-not $env:POSTGRES_USER) {
        $env:POSTGRES_USER = "postgres"
    }
    if (-not $env:POSTGRES_DB) {
        $env:POSTGRES_DB = $env:POSTGRES_USER
    }

    # Initial initdb arguments
    $initdbArgs = @("-U", "$env:POSTGRES_USER", "-E", "UTF8", "--no-locale")

    # Append arguments based on environment variables
    if ($env:POSTGRES_PASSWORD) {
        $pwFile = New-TemporaryFile
        $env:POSTGRES_PASSWORD | Out-File -FilePath $pwFile -Force -Encoding utf8
        $initdbArgs += "--pwfile", $pwFile
    }
    if ($env:POSTGRES_INITDB_WALDIR) {
        $initdbArgs += "--waldir", $env:POSTGRES_INITDB_WALDIR
    }
    if ($env:POSTGRES_INITDB_ARGS) {
        $initdbArgs += $env:POSTGRES_INITDB_ARGS.Split(' ')
    }

    # Run initdb command
    Write-Host "Initializing database..."
    echo "initdb $initdbArgs $env:PGDATA"
    & initdb $initdbArgs "$env:PGDATA"

    # Remove password file if it was created
    if ($pwFile) { Remove-Item -Path $pwFile -Force }

    # Set the authentication method based on POSTGRES_PASSWORD
    $authMethod = if ($env:POSTGRES_PASSWORD) { "scram-sha-256" } else { "trust" }
    if ($authMethod -eq "trust") {
        Write-Host "****************************************************"
        Write-Host "WARNING: No password has been set for the database."
        Write-Host "This will allow anyone with access to the Postgres port to access your database."
        Write-Host "In Docker's default configuration, this is effectively any other container on the same system."
        Write-Host "Use '-e POSTGRES_PASSWORD=password' to set it in 'docker run'."
        Write-Host "****************************************************"
    }
    Add-Content -Path "$env:PGDATA\pg_hba.conf" -Value "host all all all $authMethod"

    # Start PostgreSQL for configuration
    & pg_ctl -U "$env:POSTGRES_USER" -D "$env:PGDATA" -w start

    # Create the database if it doesn't exist
    if ($env:POSTGRES_DB -ne "postgres") {
        & psql -v ON_ERROR_STOP=1 --username "$env:POSTGRES_USER" --dbname "postgres" -Command "CREATE DATABASE $($env:POSTGRES_DB);"
    }

    # Stop PostgreSQL
    & pg_ctl -U "$env:POSTGRES_USER" -D "$env:PGDATA" -m fast -w stop

    # Configure PostgreSQL to listen on all interfaces
    Add-Content -Path "$env:PGDATA\postgresql.conf" -Value "listen_addresses = '*'"
}

# Register and start PostgreSQL service
Write-Host "Registering and starting PostgreSQL service..."
if (-not (Get-Service -Name "postgresql" -ErrorAction SilentlyContinue)) {
    & pg_ctl register -D "$env:PGDATA" -N postgresql
}
& C:\ServiceMonitor.exe postgresql
