---
published: true
title: A basic infrastructure with Docker, Chef, and Rails
subtitle: A basic infrastructure setup using the features of Docker.
author: Austen Ito
ga_id: 
created_at: 2014-07-26 13:48:08.227526 -04:00
published_at: 2014-07-26 13:48:08.228104 -04:00
layout: post
tags: infrastructure, Docker
summary:
---


# Before we get started

This tutorial expects you to have knowledge of the basic Docker concepts such as images, containers, volumes, and linking. If you aren't familiar, take a look at [Getting Started with Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-getting-started). In this post, we'll be building infrastructure in [Vagrant](http://www.vagrantup.com/) 
with the lightweight resources provided by [Chef-Docker](https://github.com/bflad/chef-docker).

Our chef kitchen, where we'll configure our environment specific variables, can be found here: [Example Chef Kitchen](https://github.com/austenito/docker-chef-rails-example)

# What isn't covered

* Zero downtime deploys - Vamsee Kanakala's talk on [Zero Downtime Deployments with Docker](https://www.youtube.com/watch?v=mQvIWIgQ1xg) at Garden City Ruby is helpful.
* Backing up your containers
* Deployment to production - I have been deploying to DigitalOcean via Chef solo, however that's a bit outside the scope of this post.

# What are we trying to build?

It's hard to explain even a simple infrastructure without a diagram. So this is what we'll be building step-by-step:

![Docker Rails Diagram](https://copy.com/ACyi0xiRhoNT0YOn)

In this diagram, each square represents a Docker container built from a Docker image. Everything a container needs to run is either found in the container (e.g. configuration files) or by
linking to other containers.

The rails application is linked to a gem cache container to avoid downloading gems everytime we deploy a container.

# Gem Cache

Before each section, I'll reference the chef recipe and the Dockerfile here:

* [Recipe](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/recipes/gem-cache.rb)
* [Dockerfile](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/gem-cache/Dockerfile)

In the Docker world, containers are ephemeral, which means data written to containers disappear when we redeploy a container. [Docker volumes](https://docs.docker.com/userguide/dockervolumes/) 
allow us to store data outside of a container. In our case, we never want to redownload a gem if it already has been downloaded.

Let's take a look at the data volume recipe:

<pre>
  <code class="language-ruby">
    include_recipe 'docker'

    # 1
    cookbook_file 'Dockerfile' do
      path '/tmp/Dockerfile'
      source 'gem-cache/Dockerfile'
    end

    # 2
    docker_image 'ubuntu' do
      tag 'gem-cache'
      source '/tmp'
      action :build_if_missing
    end

    #3
    docker_container 'gem-cache' do
      image 'ubuntu:gem-cache'
      container_name 'gem-cache'
      detach true
      action :run
    end
  </code>
</pre>

1. The first thing we need to do is copy over our [Dockerfile](http://docs.docker.com/reference/builder/) into the [context](http://docker.readthedocs.org/en/v0.5.3/commandline/command/build/) 
of the Docker build to provide the Docker daemon access to the files when building the image.

2. Next we create the Docker volume image. We set the context of the build to be `/tmp`, which is where we copied our Dockerfile
   scripts.

3. Finally, we use the image to run a container. This container is set to run bash via the `CMD` directive in the Dockerfile.

# Postgres

* [Recipe](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/recipes/postgres.rb)
* [Dockerfile](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/postgres/Dockerfile)

Let's look at the chef recipe to build our Docker image, since there's a lot more going on:

<pre>
  <code class="bash">
    # 1
    FROM austenito/ruby:2.1.2

    # 2
    RUN mkdir /postgres
    ADD Berksfile /postgres/Berksfile
    ADD solo.json /postgres/solo.json
    ADD solo.rb /postgres/solo.rb

    WORKDIR /postgres

    # 3
    RUN bash -c 'source /usr/local/share/chruby/chruby.sh; chruby 2.1.2'
    RUN berks vendor ./cookbooks
    RUN chef-solo -c solo.rb -j solo.json

    # 4
    VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

    # 5
    EXPOSE 5432
    USER postgres
    CMD ["/usr/lib/postgresql/9.3/bin/postgres",
         "-D", "/var/lib/postgresql/9.3/main", "-c",
         "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
  </code>
</pre>

1. Pull a pre-built [Ruby 2.1.2 image](https://registry.hub.docker.com/u/austenito/ruby-2.1.2/) from Docker hub. It has ruby 2.1.2 and chruby installed.

2. Add files in the Docker daemon context to our image.

3. Run chef-solo to build and configure postgres with the files we copied into our image.

4. Expose directories to other containers to allow backups of our data. If we didn't do this and the container is deleted, all of our
   data would be lost.

5. Run postgres.

Our chef recipe is similar to the gem cache with a few differences:

* We expose a port (5432) to other containers to allow tcp connections to this container
* We use [env](https://docs.docker.com/reference/builder/#env) to set environmental variables before we run our container
* We set which volumes from other containers that available in this container with [volumes_from](https://docs.docker.com/reference/builder/#volume)

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
        volumes_from 'gem-cache'
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
      volumes_from 'gem-cache'
      action :run
      port '3000:3000'
    end
  </code>
</pre>

When the rails-example container starts up, we want to be able to bundle, precompile our assets, migrate, then start our server. Specifying this inline via the `CMD` directive
is a bit cumbersome, so we can specify a script to the `CMD` directive, 
[run.sh](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/rails-example/run.sh).
The script clones the latest rails-example repository, bundles, migrates, and starts unicorn.

# Nginx

* [Recipe](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/recipes/nginx.rb)
* [Dockerfile](https://github.com/austenito/docker-chef-rails-example/blob/master/cookbooks/example-cookbook/files/default/nginx/Dockerfile)

Unlike the postgres container, which uses a chef recipe for configuration, we will configure nginx manually via apt and copying over our nginx.conf file. Using the nginx 
chef recipe turns out to be a bit too compilicated for our simple infrastructure example.

Other than that, there is nothing new to see in the recipe or the Dockerfile. Our Dockerfile installs nginx and we run a container with nginx with our chef recipe.

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

Let's ssh into our vagrant box by running `vagrant ssh` and poke around. First let see what images we created:

<pre>
  <code class="bash">
    sudo docker images

    REPOSITORY                TAG                 IMAGE ID
    austenito                 nginx               a10b38bf0975
    austenito/rails-example   latest              38c2ed56c811
    austenito/postgres        9.3                 88c026cf2326
    ubuntu                    gem-cache           11f9a661754b
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
    ubuntu:gem-cache                                         gem-cache
  </code>
</pre>

# What if I don't want to build my images from the ground up?

Great question! Part of the power of Docker is the ability to push your images (ala git style) to [Docker Hub](http://hub.docker.com/) so you don't have to rebuild images.
Ruby takes the longest to compile and I've set the `docker_image` directive in the postgres Dockerfile to point to `austenito/ruby:2.1.2`.

* [Ruby 2.1.2](https://registry.hub.docker.com/u/austenito/ruby-2.1.2/)
