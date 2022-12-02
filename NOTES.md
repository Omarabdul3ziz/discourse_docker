# Forum docker image

To build/deploy [TF-Forum](https://github.com/Omarabdul3ziz/tf-forum3)

### Dockerfile

find it in `images/forum/` it consist of three parts: 
- the base copied from `images/base/slim.Dockerfile` install all the deps needed and clone the source code repo in our case [TF-Forum](https://github.com/Omarabdul3ziz/tf-forum3) 
- the release copied from `images/base/release.Dockerfile` install the deps from `package.json` and `Gemfile` for both ruby/js apps
- the threebot part installs python, some debian packages and `requirements.pip`

### Build new image

1. edit the images map in `auto_build.rb`
2. `ruby auto_build.rb <image-name>`
3. you need to push the image to be able to launch from it.

### How to run

You either can use the `./discourse-setup` script to walk you through the configs or do it manaually.

1. copy one of yml files from the `samples/` - standalone for a full server - to `containers/` and name it as you wish -`app.yml` for example-
2. edit the content of the `app.yml` to set your configs. both is required:
   - a valid domain name refers to `host-ip:80`
   - and running smtp server. You can try [mailtrap](https://mailtrap.io/) for testing.
3. in the `./launcher` edit the image to be as the tag you defined in the `auto_rebuild.rb`
4. `./launcher rebuild app` app is the name of your yml file in containers. 

Now, find the server at the domain in the `app.yml`. the server is really big so it will take some time to be ready.

### Edits

How threebot server is run?

- the `templates/` used in `samples/` are [pups](https://github.com/samsaffron/pups)-managed templates used to bootstrap your environment.
- in `templates/web.template.yml` a new file is created that manage threebot server, and then in `/etc/service/unicorn/run` the 3bot service starts monitored by `runit` with `sv` command.

### Debugging

`./discourse-doctor` is really helpful. if you faced issues starting the app you can run it and see what is going wrong and suggestions to fix that.
