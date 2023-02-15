.PHONY: all format build test run clean create migrate

all: format build test

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

