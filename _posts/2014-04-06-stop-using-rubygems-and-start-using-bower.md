---
title: Use Bower for managing front-end assets in Rails
layout: post
author: Dave Copeland
author_url: 'http://naildrivin5.com'
created_at: 2014-04-09 11:34:50.578721 -05:00
published_at: 2014-04-09 11:34:50.580193 -05:00
tags: ruby, rails, javascript, bower
published: true
summary: Rails 4.0.4 depends on version 2.2.x of the <code>jquery-rails</code> gem which in turn bundles 1.9.1 of JQuery. Does that make <strong>any</strong> sense?  RubyGems isn't well-designed to manage front-end assets, especially those maintained outside the Rails ecosystem.  Bower, on the other hand, is.
---

Rails 4.0.4 depends on version 2.2.x of the `jquery-rails` gem which in turn bundles 1.9.1 of JQuery. Does that make *any* sense?  The latest official release of `angular-ui-bootstrap-rails` is 0.9.0, which is at least a version behind the current release of the Angular UI bootstrap directives.  When will it be updated?  `chosen-rails` version 1.1.0 bundles an old version of `chosen-jquery` that has never been officially released.  What?

As recent as a year and half ago, this mess was the only sane way to manage front-end assets in a Rails app.  Thanks to Rails
Engines, a RubyGem can be created that, when required in a Rails app, will make assets available via the asset pipeline.  

When you want to use an asset in your Rails app, you have to navigate the insanity above to figure out what version you are using.  If what you want isn't provided by a gem, the “best practice” was to just download the files and throw them in `vendor/assets`.  If your assets had inter-dependencies, you better watch out.  And if you had a non-Ruby application - forget about it.

Now, there's a better way—[Bower][bower].

Bower was created by Twitter to manage front-end assets.  It's not particular to Rails (and, like many JavaScript command-line tools, it uses NodeJS), but it works similarly to RubyGems and Bundler.  You simply create a file in your project that describes what packages you want, and use the `bower` command-line app to install them.  Bower also knows about inter-asset dependencies.  Most importantly, Bower allows you to specify _directly_ what version of an asset you want.

I'm not sure why Rails doesn't provide a better tool for this.  Perhaps someday it will, but for now, Bower is going to make your
life so much easier, especially if you use a lot of front-end assets, or need to share private assets between your apps.

## Setting it up

The handy [bower-rails](https://github.com/42dev/bower-rails) gem creates some Rake tasks for you, but also allows you to specify your dependencies in a succinct Gemfile-like format (called, naturaly, `Bowerfile`).

In your `Gemfile`:

<pre><code class='language-ruby'>gem 'bower-rails'
</code></pre>

It's important to note that this doesn't include the `bower` command-line app, it just calls into it.  You'll need to install bower, likely with `npm install bower` (which requires installing Node and NPM.  I know that's a potential yak-shaving thing, but it'll be worth it).

Then place `Bowerfile` in your root directory.  Here's an example of one that uses AngularJS, version 1.2.13:

<pre><code class='language-ruby'>asset 'angular', '1.2.13'
asset 'angular-route'
asset 'angular-resource'
asset 'angular-mocks'
asset 'angular-ui-bootstrap-bower'
</code></pre>

You then install them with `rake bower:install`.  If there are any verison incompatibilities, they will generate errors, just
like you'd see in Bundler.  Everything gets downloaded to `vendor/assets/bower_components` by default.  Because this isn't
standard Rails, you'll need to add this to your asset pipeline configuration in `config/application.rb`:

<pre><code class='language-ruby'>config.assets.paths << 
  Rails.root.join("vendor","assets","bower_components")
</code></pre>

And, finally, add your newly-managed assets to `application.js`:

<pre><code class='language-javascript'>//= require angular/angular
//= require angular-resource/angular-resource
//= require angular-route/angular-route
//= require angular-ui-bootstrap-bower/ui-bootstrap.js
//= require angular-ui-bootstrap-bower/ui-bootstrap-tpls.js
</code></pre>

That's it!  Now, your front-end assets can be managed in a sane way.  But this is only part of it.  Because Bower is so simple,
it's easy to use it to manage internal, private assets that you don't (or can't) share with the outside world.

## Managing Private Assets

I work at [Stitch Fix][stitchfix], and we have several applications that serve many different purposes.  Still, they all interact with our inventory in various ways.  Although much of that information is stored in a shared database, the official color swatches of our inventory aren't stored there.  They had been copied between various apps.  We're now using Bower to share them.  This way, when we add new colors or update the swatches, the whole team knows, and we can roll out the updates in an organized way.

[stitchfix]: http://tech.stitchfix.com/blog

Here's how to set that up.

Since a Bower version string can be a git url, a value like `git@github.com/stitchfix/colors#1.0.3` will tell Bower to get assets from the `stitchfix/colors` repo, at whatever version is tagged 1.0.3.  All we have to do is put a small file named `bower.json` into that repo:

<pre><code class='language-json'>{
  "name": "colors",
  "version": "1.0.3",
  "main": [
    "colors.css"
  ],
  "dependencies": { },
  "devDependencies": { },
  "ignore": [
    "**/.*",
    "bower_components",
    "test"
  ]
}
</code></pre>

In your `Bowerfile`, you just use the git url:

<pre><code class='language-ruby'>asset 'colors', 'git@github.com/stitchfix/colors#1.0.3'
</code></pre>

And, we add it to `application.css.scss`:

<pre><code class='language-css'>#= colors/colors
</code></pre>

That's it!  Now you can manage internal assets without RubyGems in a sane way.  This means that all your front-end assets, public
and private, are managed from one clear location, and you can re-use your internal assets for non-Ruby apps, to boot.

Next time you are tempted to use `curl` to manage your assets, try Bower instead.

[bower]: http://bower.io
