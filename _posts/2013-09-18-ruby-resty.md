---
published: true
title: Ruby Resty
subtitle: Ruby port of Resty, a command-line REST client
author: Austen Ito
ga_id: 
created_at: 2013-09-18 07:50:43 -0400
layout: post
tags: ruby gems
summary: "Software is hard. Writing cURL requests shouldn't be."
---

I spend a lot of my time working with REST APIs. At home, at work, at
hackathons, it's GET this and POST that. [Resty][1] is an amazing tool to
simplify sending multiple HTTP requests with the same data and headers. My
favorite part is having per-host configuration so you never have to worry about
remembering your cryptic, hashed API keys and header names.

It's such a great tool, except resty currently [doesn't work in zsh][3].

I wanted to submit a PR to fix the problem and started thinking maybe a
shell script isn't the best approach for community development. Coming from a
Ruby background, shell script syntax is so _hard to read_. Then I thought, "What about adding functionality to Resty? 
Can I add a new command that Resty supports? Can I have nice tests documenting functionality? 
How about some continuous integration?"

And I embarked on a [Ruby Port of Resty][7].

What started as a straight port, morphed into something I didn't expect.

I started a spike with my own REPL. Thinking more about features,
I realized I should be using something like the superb [Pry][4]. Pry allows Ruby Resty to be 
easily extensible with it's [Custom Command][5] infrastructure. Since we're using plain ol' Ruby,
we should use plain old ruby objects!

<pre><code class="language-ruby">POST /api/nyan {"name": "grumpy"} # JSON String
POST /api/nyan {name: "grumpy"}   # Ruby Hash
POST /api/nyan data               # User assigned variable in the REPL
</code></pre>

Pretty nifty.

Something Ruby Resty differs from Resty is host aliasing. Rather than specifiying a hostname, 
which maps to the config file, users can specify an easy to remember alias defined in ~/.ruby_resty.yml.

This is still a working in progress and would love some feedback. If you're interested,
submit a [ruby-resty][7] issue or reply to this post.

[1]: https://github.com/micha/resty
[2]: http://bit.ly/19X1fE2
[3]: https://github.com/micha/resty/issues/38
[4]: https://github.com/pry/pry
[5]: https://github.com/pry/pry/wiki/Custom-commands
[6]: https://twitter.com/tpitale
[7]: https://github.com/austenito/ruby-resty
[8]: https://github.com/dkaufman
