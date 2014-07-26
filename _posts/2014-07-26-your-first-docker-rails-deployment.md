---
published: true
title: your-first-docker-rails-deployment
ldfubtitle: 
author: aito
ga_id: 
created_at: 2014-07-26 13:48:08.227526 -04:00
published_at: 2014-07-26 13:48:08.228104 -04:00
layout: post
tags:
summary:
---

Before we get started, you'll need to do a couple things:

* Read the DigitalOcean [Getting Started with Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-getting-started) if you're unfamiliar with Docker.
* Setup [Vagrant](http://www.vagrantup.com/)

# Getting Started Quickly

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

# The Chef Kitchen

The first thing we'll need to do is clone the [Example Chef Kitchen](https://github.com/austenito/docker-chef-rails-example). It contains all
the files you need; container run scripts, dockerfiles, chef recipes. The kitchen has the following layout:

## Dockerfiles and Run Scripts


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
