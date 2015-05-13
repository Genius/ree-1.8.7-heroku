# Build and serve custom REE

This repo contains both a buildpack and application which is used to build and
serve tarballs of Genius's custom REE. It's pretty easy to setup and the build
will take place as part of launching the `web` process before python's
`SimpleHTTPServer` serves the tarball with `app/vendor/ruby-1.8.7`.

It's best to use an ephemeral application to build REE:

```shell

heroku create --buildpack https://github.com/ddollar/heroku-buildpack-multi.git
git push heroku master
heroku logs -t # this will show you output of `make` running on the dyno
heroku open # open up the URL where the tarball is available after build
```


