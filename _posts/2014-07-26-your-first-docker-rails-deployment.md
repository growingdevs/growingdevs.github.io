---
published: true
title: Your First Docker Rails Deployment
ldfubtitle: 
author: Austen Ito
ga_id: 
created_at: 2014-07-26 13:48:08.227526 -04:00
published_at: 2014-07-26 13:48:08.228104 -04:00
layout: post
tags:
summary:
---

# Before we get started

I'm assuming you're familiar with Docker and Vagrant. No problem if you aren't! Just read the following links and you'll be all set.

* [Getting Started with Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-getting-started)
* [Vagrant](http://www.vagrantup.com/)
* [Chef-Docker](https://github.com/bflad/chef-docker) - The chef cookbook with the LWRPs (light weight resource provider) used to manage docker.


This tutorial also has the following dependencies:

* [Example Chef Kitchen](https://github.com/austenito/docker-chef-rails-example) - The chef kitchen we'll be using in this example


# Getting started quickly

This is a tldr; for this tutorial. If you want to get up and running quickly, run the following commands:

<pre>
  <code class="bash">
    git clone https://github.com/austenito/docker-chef-rails-example
    bundle
    berks
    vagrant plugin install vagrant-omnibus
    vagrant up
  </code>
</pre>

You can visit the example app at [http://localhost:8080/](http://localhost:8080/)


# What are we trying to build?

It's hard to explain even a simple infrastructure without a diagram. So this is what we'll be building step-by-step:

![Docker Rails Diagram](https://copy.com/WkVLhvyphhLcrYFO)

Each square is a container built off images I have pushed up to [Docker Hub](http://hub.docker.com/). The only exception is the
data volume container, which is built off a base ubuntu image.

* [Ruby 2.1.2](https://registry.hub.docker.com/u/austenito/ruby-2.1.2/)
* [Postgres 9.3](https://registry.hub.docker.com/u/austenito/postgres/)
* [Nginx](https://registry.hub.docker.com/u/austenito/nginx/)

## Data Volume

The first thing we'll need to create is a [docker volume](https://docs.docker.com/userguide/dockervolumes/) that stores data we want to persist outside of
our ephemeral containers. Our data volume container has logging from each service (postgres, rails app, nginx) and also stores the configuration for each service.

Let's take a look at the [data-volume recipe](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/recipes/data-volume.rb):

<pre>
  <code class="language-ruby">
    include_recipe 'docker'

    # 1. Copy files into the context of the docker build
    cookbook_file 'Dockerfile' do
      path '/tmp/Dockerfile'
      source 'data-volume/Dockerfile'
    end

    directory('/tmp/rails-example') { action :create }

    cookbook_file 'rails-example/run.sh' do
      path '/tmp/rails-example/run.sh'
      source 'rails-example/run.sh'
    end

    ...

    # 2. Create the docker volume image
    docker_image 'ubuntu' do
      tag 'data-volume'
      source '/tmp'
      action :build_if_missing
    end

    # 3. Run the data volume container
    docker_container 'data-volume' do
      image 'ubuntu:data-volume'
      container_name 'data-volume'
      detach true
      action :run
    end
  </code>
</pre>

1. The first thing we need to do is copy over the [Dockerfile](http://docs.docker.com/reference/builder/) and configuration scripts. We are copying these
files into the _context_ of the Docker build so the Dockerfile has access to them when building the image.

2. Next we create the docker volume image. We set the context of the build to be `/tmp`, which is where we copied our Dockerfile and configuration
scripts.

3. Finally, we use the data volume docker image to run a container.

Before we go any further, how does the docker volume [Dockerfile](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/data-volume/Dockerfile) 
tie into building our image?

<pre>
  <code class="language-ruby">
    FROM ubuntu:14.04

    # 1. Add files to our image
    ADD rails-example/run.sh /config/rails-example/run.sh
    RUN chmod +x /config/rails-example/run.sh

    ADD nginx/run.sh /config/nginx/run.sh
    RUN chmod +x /config/nginx/run.sh

    ADD nginx/nginx.conf /config/nginx/nginx.conf

    RUN mkdir -p /log/nginx
    RUN mkdir -p /log/rails-example

    # 2. Expose volumes to other containers
    VOLUME  ["/pgdata", "/config", "/gems", "/log"]

    # 3. The default command
    CMD /bin/bash
  </code>
</pre>

1. The files we copied into the context of our docker build our accessed in the Dockerfile when building an image. We tell the Dockerfile
to add the configuration scripts to the docker image. 

2. In order to allow our copied files to be accessed outside of this container, we need to expose the folders where the files live. We do this
by passing an array of filepaths to the `VOLUME` command.

3. The `CMD` command is used to set the default command run by containers built off this image. Since we our only using this container to store
data, we can run `bash` instead of a long-running process.

## Postgres

Next up, let's take a look at a container running a service. 

<pre>
  <code class="language-ruby">
    # 1. Build this container from our pre-built image
    docker_image 'austenito/postgres'

    # 2. Shutdown and remove existing postgres containers
    if `sudo docker ps -a | grep postgres`.size > 0
      execute('stop container') { command "docker stop -t 60 postgres" }
      execute('remove container') { command "docker rm -f postgres" }
    end

    # 3. Run the postgres container
    docker_container 'postgres' do
      image 'austenito/postgres'
      container_name 'postgres'
      port "5432:5432"
      detach true
      env ["POSTGRES_USER=#{node['postgres']['user']}",
           "POSTGRES_PASSWORD=#{node['postgres']['password']}"
          ]
      volumes_from 'data-volume'
      action :run
    end
  </pre>
</code>

1. Part of the power of docker is being able to quickly create containers from images other people have built. We don't want to compile postgres
everytime we deploy to a new machine so we can leverage an image with postgres already compiled. To do so, I've uploaded a [Postgres 9.3](https://registry.hub.docker.com/u/austenito/postgres/)
image to [Docker Hub](http://hub.docker.com/). 

2. Once we've pulled down our image, we'll need to stop any containers running postgres. This allows us to run the deploy script without manually stopping and removing the postgres containers.
For zero-downtime deploys, you'll need to approach this differently and that's outside the scope of this tutorial.

3. Running our container is the same as our data volume except for two very important options: `env` and `volumes_from`. The `env` option allows us to pass environmental variables such as credentials
into our running container. `volumes_from` provides access to the directories exposed from our docker volume container.

At this point, you might be asking yourself why are we storing our configuration outside of each service. We don't want to store it in an image since we would need to rebuild our image and associated container everytime we want to change our configuration. 


## Rails application

## Nginx

## Putting it all together

## The Chef Kitchen

The first thing we'll need to do is clone the [Example Chef Kitchen](https://github.com/austenito/docker-chef-rails-example). It has
the Dockerfiles to create images, container run scripts, and the Chef recipes to build our containers.

To reduce the time spent building images, I'm using the following docker images that I've pushed to 

These images are the base images used by the containers. All of their depencencies and state have been compiled and
saved into these images.

(Reorganize nginx, postgres, and ruby into their own cookbooks so people can build their own images)


# Recipes

# Containers
## Dockerfiles and run scripts

In `docker-files/` you'll see the Dockerfile used to build each image 


## Recipes

/cookbooks/example-cookbooks - 

# Images

# Containers

# Container Linking

# Data Volumes

## Configuration files


# Putting it all together
Fill this out with your post: your-first-docker-rails-deployment. Use markdown.

Add code like so:
<pre><code class="language-ruby">class Cow
  def says
    puts 'moo'
  end
end

Cow.new.says #=> moo</code></pre>
