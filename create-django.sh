#!/usr/bin/env bash

set -ex

echo "Enter project name in snake_case:"
read PROJECT_NAME_SNAKE_CASE
PROJECT_NAME_HYPHENATED=${PROJECT_NAME_SNAKE_CASE//_/-}
PROJECT_NAME_CAMEL_CASE=`echo $PROJECT_NAME_SNAKE_CASE | gsed -r 's/(^|_)([a-z])/\U\2/g'`

cp -R default tmp
mv tmp/project_name/templates/project_name tmp/project_name/templates/$PROJECT_NAME_SNAKE_CASE
mv tmp/project_name tmp/$PROJECT_NAME_SNAKE_CASE
find tmp -type f | xargs sed -i '' "s/project_name/$PROJECT_NAME_SNAKE_CASE/g"
find tmp -type f | xargs sed -i '' "s/project-name/$PROJECT_NAME_HYPHENATED/g"
find tmp -type f | xargs sed -i '' "s/ProjectName/$PROJECT_NAME_CAMEL_CASE/g"

mkdir ../$PROJECT_NAME_HYPHENATED
cd ../$PROJECT_NAME_HYPHENATED
pipenv install django gunicorn dj-database-url psycopg2 django-debug-toolbar whitenoise django-enforce-host django-csp django-feature-policy sentry
pipenv run django-admin startproject $PROJECT_NAME_SNAKE_CASE .
pipenv run python manage.py startapp very_unique_string
mv very_unique_string/* $PROJECT_NAME_SNAKE_CASE
rm -rf very_unique_string

cd -
cp -R tmp/ ../$PROJECT_NAME_HYPHENATED
cd ../$PROJECT_NAME_HYPHENATED

rm $PROJECT_NAME_SNAKE_CASE/tests.py
find . -type f | xargs sed -i '' "s/VeryUniqueString/$PROJECT_NAME_CAMEL_CASE/g"
find . -type f | xargs sed -i '' "s/very_unique_string/$PROJECT_NAME_SNAKE_CASE/g"
find . -type f | xargs sed -i '' 's#docs.djangoproject.com/en/[0-9]\.[0-9]/#docs.djangoproject.com/en/stable/#g'

read -p "add '$PROJECT_NAME_SNAKE_CASE' to INSTALLED_APPS in $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings.py, then press enter to continue."
read -p "Replace DATABASE with configuration from https://github.com/jacobian/dj-database-url#usage in $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings.py, then press enter to continue."
read -p "Add '$PROJECT_NAME_SNAKE_CASE.context_processors.sentry' to context processors in $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings.py, then press enter to continue."
read -p "Configure Django Debug Toolbar according to https://django-debug-toolbar.readthedocs.io/en/stable/installation.html, then press enter to continue."
read -p "Configure Whitenoise, then press enter to continue."
read -p "Copy settings from $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings_to_copy.py to $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings.py"

rm $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings_to_copy.py
rm $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/asgi.py

make db

pipenv install --dev black==19.10b0 isort pylint pylint-django pyenchant pytest pytest-django ipython
npm install
make setup-dev
make fix-yaml
make lint-yaml
make fix-json
make lint-json
make fix-python
make test

git init
git add .
git commit --message "Initial Commit"
gh repo create
git push --set-upstream origin master

read -p "Set up Stale at https://github.com/apps/stale, then press enter to continue"

heroku apps:create $PROJECT_NAME_HYPHENATED --no-remote --region eu
heroku pipelines:create $PROJECT_NAME_HYPHENATED --app $PROJECT_NAME_HYPHENATED --stage=production --remote origin
heroku pipelines:connect $PROJECT_NAME_HYPHENATED --repo craiga/$PROJECT_NAME_HYPHENATED
heroku labs:enable runtime-dyno-metadata --app $PROJECT_NAME_HYPHENATED
heroku config:set SECRET_KEY="`pwgen --numerals --symbols --secure 100 1`" --app $PROJECT_NAME_HYPHENATED
read -p "Finish setting up app in Heroku, deploy to Heroku, then press enter to continue."

heroku run --app $PROJECT_NAME_HYPHENATED python manage.py createsuperuser

read -p "Set up Sentry, then press enter to continue."
