FROM mcr.microsoft.com/windows/servercore:ltsc2025

# Set the shell to PowerShell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Download ServiceMonitor
RUN Invoke-WebRequest -Uri 'https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.10/ServiceMonitor.exe' -OutFile 'ServiceMonitor.exe'

# Install the Visual C++ Redistributable
RUN Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile 'vc_redist.x64.exe'; \
	Start-Process -filepath 'C:\vc_redist.x64.exe' -ArgumentList '/install', '/passive', '/norestart' -Passthru | Wait-Process; \
	Remove-Item -Force 'vc_redist.x64.exe'

# Image arguments
ARG INSTALL_LINK="https://get.enterprisedb.com/postgresql/postgresql-17.2-3-windows-x64.exe"
ARG INSTALL_DIR="C:\\pgsql"
ARG DATA_DIR="C:\\pgsql\\data"

# Install PostgreSQL
RUN Invoke-WebRequest -Uri $env:INSTALL_LINK -OutFile 'pgsql.exe'; \
    Start-Process -filepath 'C:\pgsql.exe' -ArgumentList \
        '--mode', 'unattended', '--unattendedmodeui', 'none', \
        '--extract-only', 'yes', '--install_runtimes', '0', \
        '--enable-components', 'server,commandlinetools', '--prefix', $env:INSTALL_DIR -Passthru | Wait-Process; \
	Remove-Item -Force 'pgsql.exe'

# Set the environment variables
ENV PGDATA "$DATA_DIR"
ENV PGBINS "$INSTALL_DIR\\bin"

# Declare the port
EXPOSE 5432

COPY ./entrypoint.ps1 .
ENTRYPOINT "$env:PATH+=\";$env:PGBINS\";& ./entrypoint.ps1"
