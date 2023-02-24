# Todos

**An example TODO web-service using Plug and Ecto (PostgreSQL).**

## PostgreSQL

To start a PostgreSQL DB:

```shell
docker run --name todos-postgres -p 5432:5432 -e POSTGRES_PASSWORD=todos -e POSTGRES_USER=todos -d postgres
```

To drop into a psql shell

```shell
docker exec -it todos-postgres psql -U todos
```

