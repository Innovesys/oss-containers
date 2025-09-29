# PostgreSQL on Windows

This repository contains the Dockerfile and entrypoint script to build a Docker image for PostgreSQL running on Windows containers.

## Links

- [GitHub](https://github.com/Innovesys/oss-containers)
- [License](https://raw.githubusercontent.com/Innovesys/oss-containers/refs/heads/main/LICENSE)

## Supported Tags

- [`18`, `18-nanoserver-ltsc2025`, `latest`](https://github.com/Innovesys/oss-containers/blob/cf5ae3faa7a42b092d068924650b3e5db17c5de7/postgres-windows/Dockerfile.nanoserver-ltsc2025)
- [`18-servercore-ltsc2025`](https://github.com/Innovesys/oss-containers/blob/cf5ae3faa7a42b092d068924650b3e5db17c5de7/postgres-windows/Dockerfile.servercore-ltsc2025)
- [`17`, `17-servercore-ltsc2025`](https://github.com/Innovesys/oss-containers/blob/fa621e08d9cc4d45ccd49ccd610bc53ba9d0fb1e/postgres-windows/servercore-ltsc2025/Dockerfile)

## Usage

To build and run the Docker image, follow these steps:

1. **Build the Image**:
    ```sh
    docker build -t postgres-windows -f Dockerfile.nanoserver-ltsc2025 .
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
