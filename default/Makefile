default:  ## Build and serve the web site.
	pipenv run python manage.py migrate
	pipenv run python manage.py runserver

setup:  ## Install required environments and packages.
	pipenv install
	printf "DATABASE_URL=sqlite:///db.sqlite3\nCANONICAL_HOST=localhost\nSECRET_KEY=`pwgen --capitalize --numerals 50 1`\n" > .env

setup-dev:  ## Install required environments and packages for development.
	pipenv install --dev
	printf "DEBUG=1\nDATABASE_URL=sqlite:///db.sqlite3\n" > .env

test: ## Run tests.
	pipenv run pytest

check-django:  ## Check Django configuration. Will fail if DEBUG is set to true.
	pipenv run python manage.py makemigrations --check
	pipenv run python manage.py check --deploy --fail-level INFO

migrations:  ## Create Django migrations.
	pipenv run python manage.py makemigrations
	pipenv run black **/migrations/*.py
	pipenv run isort --apply **/migrations/*.py

lint-python:  ## Lint Python.
	pipenv run isort --check-only
	pipenv run black --check --diff .
	find . -iname "*.py" | xargs pipenv run pylint

fix-python:  ## Attempt to automatically fix Python issues reported by linter.
	pipenv run isort --apply
	pipenv run black .

lint-yaml: ## Lint YAML.
	npm run prettier -- **/*.yaml --check

fix-yaml: ## Attempt to fix YAML issues reported by the linter.
	npm run prettier -- **/*.yaml --write

lint-json: ## Lint JSON.
	npm run prettier -- **/*.json --check

fix-json: ## Attempt to fix JSON issues reported by the linter.
	npm run prettier -- **/*.json --write

help: ## Display this help screen.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
