.PHONY: help
help: ## Display this help screen.
	@grep -E '^\S.+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: db
db:  ## Create a database.
	createuser project_name --createdb
	psql --command "alter user project_name with encrypted password 'security_is_important';"
	createdb project_name --owner=project_name

.PHONY: db-delete
db-delete:  ## Delete database.
	dropdb project_name
	dropuser project_name

.PHONY: pyenv-virtualenv
pyenv-virtualenv:  ## Create a virtual environment managed by pyenv-virtualenv.
	pyenv install --skip-existing `cat runtime.txt | sed "s/python-//"`
	pyenv virtualenv `cat runtime.txt | sed "s/python-//"` project-name
	echo "project-name" > .python-version

.PHONY: pyenv-virtualenv-delete
pyenv-virtualenv-delete:  ## Delete a virtual environment managed by pyenv-virtualenv.
	pyenv virtualenv-delete `cat .python-version`
	rm .python-version

.PHONY: dev
dev:  ## Install all packages.
	pip install --requirement requirements.txt --requirement requirements-test.txt --requirement requirements-dev.txt
	pip-sync requirements.txt requirements-test.txt requirements-dev.txt
	npm ci

.PHONY: static
static:  ## Build static assets continuously for development.
	npx webpack --watch --mode development --devtool source-map

.env:  ## Create .env file suitable for development.
	printf "DEBUG=1\nDATABASE_URL=postgres://project_name:security_is_important@localhost/project_name\n" > .env
