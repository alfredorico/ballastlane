.PHONY: rails console test migrate setup

bundle:
	docker-compose run --rm api bundle $(filter-out $@,$(MAKECMDGOALS))

# Rails commands
rails:
	docker-compose run --rm api bin/rails $(filter-out $@,$(MAKECMDGOALS))

# Common shortcuts
console:
	docker-compose run --rm api bin/rails console

test:
	docker-compose run --rm api bin/rails test

migrate:
	docker-compose run --rm api bin/rails db:migrate

pg:
	docker-compose exec db psql -U postgres

shell:
	docker-compose run --rm api bash

# Project setup
setup:
	docker-compose build --no-cache
	docker-compose run --rm api bin/setup --skip-server
	docker-compose run --rm -e RAILS_ENV=test api bin/rails db:create

rspec:
	docker-compose run --rm api bundle exec rspec $(filter-out $@,$(MAKECMDGOALS))

up:
	docker-compose up
	
down:
	docker-compose down

restart:
	docker-compose restart

npm:
	docker-compose run --rm frontend npm $(filter-out $@,$(MAKECMDGOALS))	

# Catch-all rule for arguments
%:
	@: