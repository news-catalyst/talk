# Building the docker image

```
cd talk
docker build --ssh default .
```

Grab the image ID from `docker images` for the next section.

# Deploying to Heroku

```
docker tag $imageID registry.heroku.com/coral-talk-dev/web
docker push registry.heroku.com/coral-talk-dev/web
```

To update the application on Heroku, I first open the logs in one terminal window:

```
heroku logs --tail -a coral-talk-dev
```

Then in a new window I run this command:

```
heroku container:release web -a coral-talk-dev
```

heroku open -a coral-talk-dev
