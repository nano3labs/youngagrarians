youngagrarians
==============

Growing the next generation of farmers

Install
=======

- Mount a volumen at config/secrets with devise_token & secure_token files ( generate with your preferred random token generator or rake secret > file_name)

```
cp configs/database.docker-compose.yml configs/database.yml
cp docker-compose.override.yml.template docker-compose.override.yml
```

Modify the docker-compose override environment setting to "production" if desired.
You may want to restore a database clone with `psql -f <file>` [inside the container.](https://hub.docker.com/_/postgres/) to the postgres container.

```
docker-compose up
```

If you need to apply DB migrations:
```
docker exec -it youngagrarians_app_1 rake db:migrate
```

If you need to update static files:
```
docker exec -it youngagrarians_app_1 rake assets:precompile
```


Admin Panel
===========

To access the admin panel go to `/login` and login as the following user:

email: dentsara@gmail.com
password: test42

Heroku Repo
===========
- https://git.heroku.com/youngagrarians.git

Note the pg is not used as the db, cleardb powered mysql is.  Access via mysql client and details from heroku config.
echo "SET standard_conforming_strings = 'off';\nSET backslash_quote = 'on';\n" > tmp/db_dump.sql
mysqldump -h us-cdbr-east-04.cleardb.com -u USEr -p DB  --compatible=postgresql >> tmp/db_dump.sql
Note that id columns need to be turned into serial columns and tinyints into booleans


Admin
=====

You'll want to get into the admin area; easiest way is from a rails console:
rails c(onsole)?
x = User.first && x.password = 'cl4rkrul3s' && x.save!
puts x.email
exit
then login via /admin/login with those details.
