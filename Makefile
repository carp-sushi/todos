.PHONY: all format build test run clean create migrate psql

all: format build

format:
	@mix format

build:
	@mix compile

test:
	@mix test

run:
	@mix run --no-halt

clean:
	@mix clean

create:
	@mix ecto.create

migrate:
	@mix ecto.migrate

psql:
	@docker exec -it todos-postgres psql -U todos
