#!/usr/bin/env bash

set -ex

LC_CTYPE=C
LANG=C

rm -rf tmp

echo "Enter project name in snake_case:"
read PROJECT_NAME_SNAKE_CASE
PROJECT_NAME_HYPHENATED=${PROJECT_NAME_SNAKE_CASE//_/-}
PROJECT_NAME_CAMEL_CASE=`echo $PROJECT_NAME_SNAKE_CASE | gsed -r 's/(^|_)([a-z])/\U\2/g'`

echo "Python versions available:"
pyenv versions

echo "Enter the version of Python you're targeting:"
read PYTHON_VERSION

cp -R default tmp
mv tmp/project_name/templates/project_name tmp/project_name/templates/$PROJECT_NAME_SNAKE_CASE
mv tmp/project_name tmp/$PROJECT_NAME_SNAKE_CASE
find tmp -type f | xargs sed -i '' "s/project_name/$PROJECT_NAME_SNAKE_CASE/g"
find tmp -type f | xargs sed -i '' "s/project-name/$PROJECT_NAME_HYPHENATED/g"
find tmp -type f | xargs sed -i '' "s/ProjectName/$PROJECT_NAME_CAMEL_CASE/g"
find tmp -type f | xargs sed -i '' "s/PYTHON_VERSION/$PYTHON_VERSION/g"

mkdir ../$PROJECT_NAME_HYPHENATED
cp tmp/runtime.txt ../$PROJECT_NAME_HYPHENATED
cp tmp/Makefile ../$PROJECT_NAME_HYPHENATED
cp tmp/requirements.in ../$PROJECT_NAME_HYPHENATED
cp tmp/requirements-test.in ../$PROJECT_NAME_HYPHENATED
cp tmp/requirements-dev.in ../$PROJECT_NAME_HYPHENATED
cp tmp/package.json ../$PROJECT_NAME_HYPHENATED
cd ../$PROJECT_NAME_HYPHENATED

make pyenv-virtualenv
pip install pip-tools
pip-compile requirements.in
pip-compile requirements-test.in
pip-compile requirements-dev.in
pip install --requirement requirements.txt --requirement requirements-test.txt --requirement requirements-dev.txt
npm install

django-admin startproject $PROJECT_NAME_SNAKE_CASE .
python manage.py startapp very_unique_string
mv very_unique_string/* $PROJECT_NAME_SNAKE_CASE
rm -rf very_unique_string

cd -
cp -R tmp/ ../$PROJECT_NAME_HYPHENATED
cd ../$PROJECT_NAME_HYPHENATED

rm $PROJECT_NAME_SNAKE_CASE/tests.py
find . -type f | xargs sed -i '' "s/VeryUniqueString/$PROJECT_NAME_CAMEL_CASE/g"
find . -type f | xargs sed -i '' "s/very_unique_string/$PROJECT_NAME_SNAKE_CASE/g"
find . -type f | xargs sed -i '' 's#docs.djangoproject.com/en/[0-9]\.[0-9]/#docs.djangoproject.com/en/stable/#g'

read -p "Add 'debug_toolbar', '$PROJECT_NAME_SNAKE_CASE' to INSTALLED_APPS in $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings.py, then press enter to continue."
read -p "Add 'enforce_host.EnforceHostMiddleware', 'csp.middleware.CSPMiddleware', 'django_permissions_policy.PermissionsPolicyMiddleware', 'whitenoise.middleware.WhiteNoiseMiddleware', 'debug_toolbar.middleware.DebugToolbarMiddleware' to MIDDLEWARE in $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings.py, then press enter to continue."
read -p "Copy settings from $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings_to_copy.py to $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings.py"
read -p "Add '$PROJECT_NAME_SNAKE_CASE.context_processors.sentry' to context processors in $PROJECT_NAME_HYPHENATED/$PROJECT_NAME_SNAKE_CASE/settings.py, then press enter to continue."

rm $PROJECT_NAME_SNAKE_CASE/settings_to_copy.py
rm $PROJECT_NAME_SNAKE_CASE/asgi.py

make db

isort .
black .
npx prettier --write .

mkdir staticfiles
make .env
python manage.py migrate
npx webpack
pre-commit install

echo "Enter this app's GitHub user or organization:"
read GITHUB_USER

git init
git add .
git commit --message "Initial Commit"
git branch -m main
gh repo create "$GITHUB_USER/$PROJECT_NAME_HYPHENATED"
git push --set-upstream origin main

read -p "Set up Stale at https://github.com/apps/stale, then press enter to continue"

echo "Enter this app's Heroku team:"
read HEROKU_TEAM

heroku apps:create $PROJECT_NAME_HYPHENATED --no-remote --region eu --team $HEROKU_TEAM
heroku pipelines:create $PROJECT_NAME_HYPHENATED --app $PROJECT_NAME_HYPHENATED --stage=production --remote origin --team $HEROKU_TEAM
heroku pipelines:connect $PROJECT_NAME_HYPHENATED --repo $GITHUB_USER/$PROJECT_NAME_HYPHENATED
heroku reviewapps:enable --pipeline $PROJECT_NAME_HYPHENATED
heroku labs:enable runtime-dyno-metadata --app $PROJECT_NAME_HYPHENATED
heroku config:set SECRET_KEY="`pwgen --numerals --symbols --secure 100 1`" --app $PROJECT_NAME_HYPHENATED
read -p "Finish setting up automatic deployment in Heroku, deploy to Heroku, then press enter to continue."

heroku run --app $PROJECT_NAME_HYPHENATED python manage.py createsuperuser

read -p "Set up Sentry, then press enter to continue."
