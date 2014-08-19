---
published: true
title: A basic infrastructure with Docker, Chef, and Rails
subtitle: A basic infrastructure setup using the features of Docker.
author: Austen Ito
ga_id: 
created_at: 2014-07-26 13:48:08.227526 -04:00
published_at: 2014-07-26 13:48:08.228104 -04:00
layout: post
tags: infrastructure, docker
summary:
---

# Before we get started

I'm assuming you're familiar with Docker and Vagrant. If not, take a look at following articles:

* [Getting Started with Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-getting-started)
* [Vagrant](http://www.vagrantup.com/)
* [Chef-Docker](https://github.com/bflad/chef-docker) - The chef cookbook used to manage docker.


We'll be using an [Example Chef Kitchen](https://github.com/austenito/docker-chef-rails-example) throughout this blog.

# What isn't covered

* Zero downtime deploys - Vamsee Kanakala's talk on [Zero Downtime Deployments with Docker](https://www.youtube.com/watch?v=mQvIWIgQ1xg) at Garden City Ruby is helpful.
* Backing up your containers
* Deployment to production - I have been deploying to DigitalOcean via Chef solo, however that's a bit outside the scope of this post.

# What are we trying to build?

It's hard to explain even a simple infrastructure without a diagram. So this is what we'll be building step-by-step:

![Docker Rails Diagram](https://copy.com/ACyi0xiRhoNT0YOn)

When building each image, I use the following pattern:

* Copy a Dockerfile and related files into a directory onto the host machine.
* Set the Docker daemon context to the directory with the copied files.
* Build the docker image using the Dockerfile.
* Set the default command in the Dockerfile to execute either the service itself or a bash script.

# Data Volume

Before each section, I'll reference the chef recipe and the Dockerfile here:

* [Recipe](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/recipes/data-volume.rb)
* [Dockerfile](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/data-volume/Dockerfile)

The first thing we'll need to create is a [docker volume](https://docs.docker.com/userguide/dockervolumes/) storing data we want to persist outside of
our ephemeral containers. Our volume stores logs for our rails application, unicorn, and nginx. It also serves as a gem cache. Without the cache, our deploys
would take forever since each container would need to download the same gem.

Let's take a look at the data volume recipe:

<pre>
  <code class="language-ruby">
    include_recipe 'docker'

    # 1
    cookbook_file 'Dockerfile' do
      path '/tmp/Dockerfile'
      source 'data-volume/Dockerfile'
    end

    # 2
    docker_image 'ubuntu' do
      tag 'data-volume'
      source '/tmp'
      action :build_if_missing
    end

    #3
    docker_container 'data-volume' do
      image 'ubuntu:data-volume'
      container_name 'data-volume'
      detach true
      action :run
    end
  </code>
</pre>

1. The first thing we need to do is copy over our [Dockerfile](http://docs.docker.com/reference/builder/) to build our docker volume image. We copy the Dockerfile 
   into the _context_ of the Docker build to provide the Docker daemon access to the files when building the image.

2. Next we create the docker volume image. We set the context of the build to be `/tmp`, which is where we copied our Dockerfile
   scripts.

3. Finally, we use the data volume docker image to run a container.

Our containers are running a default command set by each image's Dockerfile. Our data volume's Dockerfile is fairly basic since it only runs a bash shell.

# Postgres

* [Recipe](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/recipes/postgres.rb)
* [Dockerfile](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/postgres/Dockerfile)

Let's look at the chef recipe to build our docker image, since there's a lot more going on:

<pre>
  <code class="bash">
    ...

    # 1
    RUN mkdir /postgres
    ADD Berksfile /postgres/Berksfile
    ADD solo.json /postgres/solo.json
    ADD solo.rb /postgres/solo.rb

    WORKDIR /postgres

    # 2
    RUN bash -c 'source /usr/local/share/chruby/chruby.sh; chruby 2.1.2'
    RUN berks vendor ./cookbooks
    RUN chef-solo -c solo.rb -j solo.json

    # 3
    VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

    EXPOSE 5432

    USER postgres

    # 4
    CMD ["/usr/lib/postgresql/9.3/bin/postgres",
         "-D", "/var/lib/postgresql/9.3/main", "-c",
         "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
  </code>
</pre>

1. The Dockerfile is responsible for adding files to our docker image. These files are relative to docker daemon context.

2. Run chef-solo to build and configure postgres with the files we copied into our image.

3. Expose directories to other containers to allow backups of our data. If we didn't do this and the container is deleted, all of our
   data would be lost.

4. Run postgres.

Our chef recipe is similar to the data volume except when we run our container as we specify `env` and `volumes_from`.

* `env` allows us to pass environmental variables such as credentials into our running container. 
* `volumes_from` provides access to the directories exposed from our docker volume container. 

<pre>
  <code class="language-ruby">
    ...

    if `sudo docker ps -a | grep postgres`.size == 0
      docker_container 'postgres' do
        image 'austenito/postgres:9.3'
        container_name 'postgres'
        port "5432:5432"
        detach true
        env ["POSTGRES_USER=#{node['postgresql']['user']}",
             "POSTGRES_PASSWORD=#{node['postgresql']['password']}"
            ]
        volumes_from 'data-volume'
        action :run
      end
    end
  </code>
</pre>


# Rails application

* [Recipe](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/recipes/rails-example.rb)
* [Dockerfile](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/rails-example/Dockerfile)

Our Rails application container uses the `link` directive to provide
[container linking](https://docs.docker.com/userguide/dockerlinks/#docker-container-linking). This exposes environment
variables with ip and port information of postgres container.

<pre>
  <code class="language-ruby">
    ...

    docker_container 'rails-example' do
      image 'austenito/rails-example'
      container_name 'rails-example'
      detach true
      link ['postgres:db']
      volumes_from 'data-volume'
      action :run
      port '3000:3000'
    end
  </code>
</pre>

When the rails-example container starts up, we want to be able to bundle, precompile our assets, migrate, then start our server. Specifying this inline via the `CMD` directive
is a bit cumbersome, so we can specify a script, [run.sh](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/rails-example/run.sh)
to execute. The script clones the latest rails-example repository, bundles, migrates, and starts unicorn.

# Nginx

* [Recipe](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/recipes/nginx.rb)
* [Dockerfile](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/nginx/Dockerfile)

Nginx is configured manually by installing nginx via apt and copying over our the nginx.conf file. For our purposes, setting up the nginx recipe is _way_ to
complicated and not worth an simple infrastructure setup.

# Putting it all together

We're ready to deploy our infrasture to vagrant. Run the following commands:

<pre>
  <code class="bash">
    git clone https://github.com/austenito/docker-chef-rails-example
    bundle
    berks
    vagrant plugin install vagrant-omnibus
    vagrant up
  </code>
</pre>

If everything went right the first time (it always does right?), you can visit the example app at [http://localhost:8080/](http://localhost:8080/). 

Let's ssh into our vagrant box and poke around. First let see what images we created:

<pre>
  <code class="bash">
    sudo docker images

    REPOSITORY                TAG                 IMAGE ID
    austenito                 nginx               a10b38bf0975
    austenito/rails-example   latest              38c2ed56c811
    austenito/postgres        9.3                 88c026cf2326
    ubuntu                    data-volume         11f9a661754b
    ubuntu                    14.04               c4ff7513909d
    austenito/ruby            2.1.2               c794944b5fa2
  </code>
</pre>

These images were built by the `docker_image` directive in our chef recipes. They are used to create and run the containers below:

<pre>
  <code class="bash">
    sudo docker ps -a

    IMAGE                           PORTS                    NAMES
    austenito:nginx                 0.0.0.0:80->80/tcp       nginx
    austenito/rails-example:latest  0.0.0.0:3000->3000/tcp   nginx/rails_example,rails-example
    austenito/postgres:9.3          0.0.0.0:5432->5432/tcp   nginx/rails_example/db,postgres,rails-example/db
    ubuntu:data-volume                                       data-volume
  </code>
</pre>

# What if I don't build my images from the ground up?

Great question! Part of the power of docker is the ability to push your images (ala git style) to [Docker Hub](http://hub.docker.com/) so you don't have to rebuild images.
Ruby takes the longest to compile and I've set the `docker_image` directive in the postgres Dockerfile to point to `austenito/ruby:2.1.2`.

* [Ruby 2.1.2](https://registry.hub.docker.com/u/austenito/ruby-2.1.2/)
