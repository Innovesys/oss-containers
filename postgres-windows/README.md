# PostgreSQL on Windows

This repository contains the Dockerfile and entrypoint script to build a Docker image for PostgreSQL running on Windows containers.

## Usage

To build and run the Docker image, follow these steps:

1. **Build the Image**:
    ```sh
    docker build -t postgres-windows .
    ```

2. **Run the Container**:
    ```sh
    docker run -d -p 5432:5432 --isolation process postgres-windows
    ```
> [!NOTE]  
> Running the container with `--isolation process` is recommended to avoid shared memory issues.

## Environment Variables

- `POSTGRES_DB`: The name of the default database to create. Defaults to `postgres`.
- `POSTGRES_USER`: The username for the PostgreSQL database. Defaults to `postgres`.
- `POSTGRES_PASSWORD`: The password for the PostgreSQL database. Defaults to `POSTGRES_USER`'s value.

## Volumes

To persist data, you can mount a volume to the PostgreSQL data directory:

```sh
docker run -d -p 5432:5432 -v "$(pwd)/data:c:/pgsql/data" --isolation process postgres-windows
```
