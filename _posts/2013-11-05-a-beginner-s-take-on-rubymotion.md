---
published: false
title: A Beginner's Take on RubyMotion
subtitle:
author: Travis Valentine
ga_id:
created_at: 2013-11-05 12:25:14.885273 -05:00
layout: post
tags: RubyMotion
summary: "A few of the benefits of using the RubyMotion toolchain to develop iOS apps from a beginner's perspective."
---

>"A little over a year ago I was in bondage,
>and now I'm back out here reaping the blessings
>and getting the benefits that go along with it"
>- Pimp C's last interview, from Jay-Z's _FuckWithMeYouKnowIGotIt_

Like many others, I initially started to program because I had an idea. After a brief stint with PHP, I dove into Ruby/Rails and started developing my app, [YourTurn](http://yourturn.org). During development, there was a lot I wanted to learn about the technologies (and their minutiae) I was discovering, but my focus was getting something tangible to appear on my screen. This not only helped me prototype my app, but also drove me to learn more. (Topic for a future post? You bet.)

When I set out to make an iOS app for YourTurn, I faced a similar decision: either learn a new language - Objective C - or utilize something I was more familiar with to get something done. To be honest, I didn't really consider the latter until I heard about RubyMotion, and when I did the choice was easy.\*

You can learn more about RubyMotion on its [website](http://www.rubymotion.com/), but I want to use my inaugural post here to highlight a few of the benefits from the perspective of a new Ruby developer. First: RubyMotion's use of, well, Ruby.

For example, here's Objective-C syntax:

<pre><code class="language-objectivec">[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];</code></pre>

Here's RubyMotion:

<pre><code class="language-ruby">UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)</code></pre>

I don't know about you, dear reader, but I find the RubyMotion way more readable as well as easier to type.\*\*

As a beginner, a technology is only as valuable to me as the community supporting it. From the folks at HipByte to the authors of its many [wrappers and libraries](http://rubymotion-wrappers.com/), it's clear that the folks behind RubyMotion want it to succeed. I'm less than a year into the toolchain but I can confidently say I wouldn't have been able to release version 1.0.0 of my app if it weren't for resources like Clay Allsopp's [tutorial](http://rubymotion-tutorial.com/) and [PragProg book](http://pragprog.com/book/carubym/), as well as [BubbleWrap](http://bubblewrap.io/), [Formotion](https://github.com/clayallsopp/formotion), and [Sugarcube](https://github.com/rubymotion/sugarcube). Resources like these continue to grow each day, and I know I'll continue to lean on them as I release future versions.

For me though, the best thing about RubyMotion is that it removes extraneous complexity from learning about Apple's APIs. By not having to worry about areas in which I really lack expertise (namely Xcode and Objective-C) I can focus on making my app better. Of course, as I become more familiar with the APIs I could move to learning more about Objective-C if I wanted. But again, I wouldn't have that choice without RubyMotion. With it I can prioritize learning the things that help me reach my ultimate goal of improving my app quickly.

So am I saying RubyMotion is for everyone? No. It's obviously best for people with varying degrees of Ruby knowledge.

Is it perfect? No. A few downsides are that:

1) It is not fully [open source](http://merbist.com/2012/05/04/macruby-on-ios-rubymotion-review/).
2) It has had some big issues like [RM-3](http://joshsymonds.com/blog/2013/06/26/why-im-not-using-rubymotion-in-production/) (which, in fairness was prioritized and resolved by HipByte).
3) It is a bit [tricky with blocks](https://groups.google.com/d/msg/rubymotion/-5QkGWvo9ew/epqVwJ2I7T8J).
4) The license is pricey at [$199.99](http://sites.fastspring.com/hipbyte/product/rubymotion).

Collectively, these issues represent exactly what RubyMotion is: a growing toolchain from a bootstrapped business. Aside from the price, they shouldn't dissuade anyone from getting their hands dirty.

Simply put: for Ruby developers, RubyMotion provides a lower barrier of entry to iOS Development. For beginners like me, it's the best tool to use if you want to get an app out quickly. For that, I'm grateful to HipByte and the community behind RubyMotion.

\* I know there are other frameworks that utilize technologies such as HTML/CSS/JavaScript but I haven't seen any that deliver experiences similar to those that come from native apps. Perhaps these frameworks are the future - and I'll certainly keep an eye on them - but it's just not there yet.

\*\* Granted, this is because my background is in Ruby and that's all I know. But still.