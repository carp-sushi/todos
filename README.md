# Todos

**An example TODO web-service using Plug and Ecto (PostgreSQL).**

## PostgreSQL

alias postgresql='docker run --rm --name todos-postgres -p 5432:5432 -e POSTGRES_PASSWORD=todos -e POSTGRES_USER=todos -d postgres'
alias psql='docker exec -it todos-postgres psql -U todos'

