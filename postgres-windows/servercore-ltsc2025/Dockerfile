FROM mcr.microsoft.com/windows/servercore:ltsc2025

# Set the shell to PowerShell
# For some reason, double quotes in RUN commands are consumed by Docker unless they are escaped
# but single quotes are not affected.
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Download ServiceMonitor
RUN Invoke-WebRequest -Uri 'https://github.com/microsoft/IIS.ServiceMonitor/releases/download/v2.0.1.10/ServiceMonitor.exe' -OutFile 'ServiceMonitor.exe'

# Install the Visual C++ Redistributable
RUN Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile 'setup.exe'; \
    & .\setup.exe /install /passive /norestart | Out-Default; \
    if ($LASTEXITCODE -ne 0) { throw \"vcredist installer failed with exit code $LASTEXITCODE\" }; \
	Remove-Item -Force 'setup.exe'

# Image arguments
ARG INSTALL_LINK="https://get.enterprisedb.com/postgresql/postgresql-18.0-1-windows-x64.exe"
ARG INSTALL_DIR="C:\\pgsql"
ARG DATA_DIR="C:\\pgsql\\data"

# Install PostgreSQL
RUN Invoke-WebRequest -Uri \"$env:INSTALL_LINK\" -OutFile 'setup.exe'; \
    & .\setup.exe --mode unattended --unattendedmodeui none --extract-only yes \
        --install_runtimes 0 --enable-components 'server,commandlinetools' \
        --prefix \"$env:INSTALL_DIR\" | Out-Default; \
    if ($LASTEXITCODE -ne 0) { throw \"PostgreSQL installer failed with exit code $LASTEXITCODE\" }; \
	Remove-Item -Force 'setup.exe'

# Set the environment variables
ENV PGDATA "$DATA_DIR"
ENV PGBINS "$INSTALL_DIR\\bin"

# Declare the port
EXPOSE 5432

COPY ./entrypoint.ps1 .
ENTRYPOINT "$env:PATH+=\";$env:PGBINS\";& ./entrypoint.ps1"
