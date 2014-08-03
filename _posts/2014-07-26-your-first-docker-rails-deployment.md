---
published: true
title: Your First Docker Rails Deployment
subtitle: 
author: Austen Ito
ga_id: 
created_at: 2014-07-26 13:48:08.227526 -04:00
published_at: 2014-07-26 13:48:08.228104 -04:00
layout: post
tags: infrastructure, docker
summary:
---

# Before we get started

I'm assuming you're familiar with Docker and Vagrant. If you aren't, just read the following articles and you'll be all set.

* [Getting Started with Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-getting-started)
* [Vagrant](http://www.vagrantup.com/)
* [Chef-Docker](https://github.com/bflad/chef-docker) - The chef cookbook used to manage docker.


This tutorial also has the following dependencies:

* [Example Chef Kitchen](https://github.com/austenito/docker-chef-rails-example) - The chef kitchen we'll be using in this example


# What are we trying to build?

It's hard to explain even a simple infrastructure without a diagram. So this is what we'll be building step-by-step:

![Docker Rails Diagram](https://copy.com/WkVLhvyphhLcrYFO)

## Data Volume

The first thing we'll need to create is a [docker volume](https://docs.docker.com/userguide/dockervolumes/) storing data we want to persist outside of
our ephemeral containers. Our volume has logging from each service (postgres, rails app, nginx) and also stores the configuration for each service.

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

1. The first thing we need to do is copy over the [Dockerfile](http://docs.docker.com/reference/builder/) and configuration scripts. All of our configuration
scripts (postgres, nginx, rails application) are copied over. We are copying these files into the _context_ of the Docker build to provide the Docker daemon access 
to the files when building the image.

2. Next we create the docker volume image. We set the context of the build to be `/tmp`, which is where we copied our Dockerfile and configuration
scripts.

3. Finally, we use the data volume docker image to run a container.

Before we go any further, how does the docker volume [Dockerfile](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/data-volume/Dockerfile) 
tie into building our image?

<pre>
  <code class="language-ruby">
    FROM ubuntu:14.04

    # 1. Copy configuration into the image
    ADD rails-example/run.sh /config/rails-example/run.sh
    RUN chmod +x /config/rails-example/run.sh

    ADD nginx/run.sh /config/nginx/run.sh
    RUN chmod +x /config/nginx/run.sh
    ADD nginx/nginx.conf /config/nginx/nginx.conf

    ADD postgres/run.sh /config/postgres/run.sh
    RUN chmod +x /config/postgres/run.sh
    ADD postgres/postgresql.conf /config/postgres/postgresql.conf
    ADD postgres/pg_hba.conf /config/postgres/pg_hba.conf

    RUN mkdir -p /log/nginx
    RUN mkdir -p /log/rails-example

    # 2. Add VOLUMEs to allow backup of config, logs and databases
    VOLUME  ["/pgdata", "/config", "/gems", "/log"]

    # 3. Default container command
    CMD /bin/bash
  </code>
</pre>

1. The files we copied into the context of our Docker build are accessed in the Dockerfile when building an image. We use the `ADD` directive to 
tell Docker to add the configuration scripts to the docker image.

2. To expose our copied files to other containers, we `EXPOSE` the folders where the files live.

3. The `CMD` directive sets the default command run by containers built off this image. Since we our only using this container to store
data, we can run `bash` instead of a long-running process.

## Postgres

Next up, let's take a look at a recipe building a container running postgres:

<pre>
  <code class="language-ruby">
    include_recipe 'docker'

    # 1. Shutdown and remove existing postgres containers
    if `sudo docker ps -a | grep postgres`.size > 0
      execute('stop container') { command "docker stop -t 60 postgres" }
      execute('remove container') { command "docker rm -f postgres" }
    end

    # 2. Run the postgres container
    docker_container 'postgres' do
      image 'ubuntu:postgres'
      container_name 'postgres'
      port "5432:5432"
      detach true
      env ["POSTGRES_USER=#{node['postgres']['user']}",
           "POSTGRES_PASSWORD=#{node['postgres']['password']}"
          ]
      volumes_from 'data-volume'
      action :run
      command '/config/postgres/run.sh'
    end
    docker_image 'austenito/postgres'
  </code>
</pre>

1. Before we run our container, we'll need to stop any containers with the same name. This allows us to deploy without manually stopping and 
removing the postgres containers. In a zero-downtime deployment, we would shut down and start a different set of containers.

2. Running our container is the same as our data volume except for a few important options: `env`, `volumes_from`, and `command`.

* `env` allows us to pass environmental variables such as credentials
into our running container. 
* `volumes_from` provides access to the directories exposed from our docker volume container. 
* `command` is the command executed when the container is started. In this case we running [run.sh](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/postgres/run.sh), 
which sets up our intial postgres credentials and starts postgres.

## Rails application and Nginx

Next up, is our Rails application, which is setup the same way as our postgres container. We shutdown any running containers and start a new container with
volumes from our docker volume.

The only difference here is the `link` directive. `link` provides [container linking](https://docs.docker.com/userguide/dockerlinks/#docker-container-linking), which 
exposes environmental variables with ip and port information of our postgres container.

<pre>
  <code class="language-ruby">
    include_recipe 'docker'

    if `sudo docker ps -a | grep rails-example`.size > 0
      execute('stop container') { command "docker stop -t 60 rails-example" }
      execute('remove container') { command "docker rm -f rails-example" }
    end

    docker_container 'rails-example' do
      image 'ubuntu:ruby-2.1.2'
      container_name 'rails-example'
      detach true
      link ['postgres:db']
      volumes_from 'data-volume'
      action :run
      port '3000:3000'
      command '/config/rails-example/run.sh'
    end
  </code>
</pre>

[Nginx](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/recipes/nginx-run.rb) is configured the same way as our 
Rails application. Nothing more to see here.

## Putting it all together

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
    REPOSITORY           TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    ubuntu               postgres            457e0b4c8bc7        1 hours ago        344 MB
    ubuntu               data-volume         ea0b18907d65        1 hours ago        192.8 MB
    ubuntu               nginx               bd25b4ce9f7a        1 hours ago        238.9 MB
    ubuntu               ruby-2.1.2          b275a1035b10        1 hours ago        895.2 MB
    ubuntu               14.04               ba5877dc9bec        1 days ago         192.7 MB
  </code>
</pre>

These images were built by the `docker_image` directive in our chef recipes. They are used to create and run the containers below:

<pre>
  <code class="bash">
    vagrant ssh
    sudo docker images

    CONTAINER ID        IMAGE                COMMAND                CREATED             STATUS                    PORTS                    NAMES
    a5f4e5b78071        ubuntu:nginx         /config/nginx/run.sh   1 hours ago        Up 1 hours               0.0.0.0:80->80/tcp       nginx
    3313481b47bf        ubuntu:ruby-2.1.2    /config/rails-exampl   1 hours ago        Up 1 hours               0.0.0.0:3000->3000/tcp   nginx/rails_example,rails-example
    542defb41bb9        ubuntu:postgres      /config/postgres/run   1 hours ago        Up 1 hours               0.0.0.0:5432->5432/tcp   nginx/rails_example/db,postgres,rails-example/db
    e65738481020        ubuntu:data-volume   /bin/sh -c /bin/bash   1 hours ago        Exited (0) 1 hours ago                            data-volume
  </code>
</pre>

# What if I don't build my images from the ground up?

Great question! Part of the power of docker is the ability to push your images (ala git style) to [Docker Hub](http://hub.docker.com/). You'll be able to
change the `docker_image` directive to point to `austenito/ruby-2.1.2`, `austenito/postgres` or any pre-built image you would like.

* [Ruby 2.1.2](https://registry.hub.docker.com/u/austenito/ruby-2.1.2/)
* [Postgres 9.3](https://registry.hub.docker.com/u/austenito/postgres/)
* [Nginx](https://registry.hub.docker.com/u/austenito/nginx/)

## Why are we storing our configuration outside of each service's container?

Through this whole process, you were probably asking yourself why would we store our configuration outside of each service. If our configuration lived in each image
we would need to rebuild 
we would need to rebuild our image and associated container everytime we want to change our configuration. 


