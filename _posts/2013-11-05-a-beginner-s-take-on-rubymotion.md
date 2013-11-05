---
published: false
title: A Beginner's Take on RubyMotion
subtitle:
author: Travis Valentine
ga_id:
created_at: 2013-11-05 12:25:14.885273 -05:00
layout: post
tags: RubyMotion
summary:
---

Like many others, I initially started to program because I had an idea. After a brief stint with PHP, I dove into Ruby/Rails and started developing my app, [YourTurn](http://yourturn.org). During development, there was a  lot I wanted to learn about the technologies (and their minutiae) I was discovering, but my focus was getting something tangible to appear on my screen. Not only to prototype my app, but also because seeing results drove me to learn more which is important for beginners such as myself. (Topic for a future post? You bet.)

When I set out to make an iOS app for YourTurn, I faced a similar decision: either learn a new language - Objective C - or utilize something I was more familiar with to get something done. To be honest, I didn't really consider the latter until I heard about RubyMotion, and when I did the choice was easy.*

You can learn more about RubyMotion on its [website](http://www.rubymotion.com/), but I want to use my inaugural post here to highlight a few of the benefits from the perspective of a new Ruby developer. First: RubyMotion's use of, well, Ruby.

For example, here's Objective-C syntax:

    [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

Here's RubyMotion:

    UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

I don't know about you, dear reader, but I find the RubyMotion way much more readable as well as easier to type.**

As a beginner, a technology is only as valuable to me as the community supporting it. From the folks at HipByte to the authors of its many [wrappers and libraries](http://rubymotion-wrappers.com/), it's clear that the folks behind RubyMotion want it to succeed. I'm less than a year into the toolchain but I can confidently say I wouldn't have been able to release version 1.0.0 of my app if it weren't for resources like Clay Allsopp's tutorial and PragProg book, as well as BubbleWrap, Formotion, and Sugarcube. Resources like these continue to grow each day, and I know I'll continue to lean on them as I release future versions.

For me though, the best thing about RubyMotion is that it removes extraneous complexity from learning about Apple's APIs. By not having to worry about areas in which I really lack expertise (namely Xcode and Objective-C) I can focus on making my app better. Of course, as I become more familiar with the APIs I could move to learning more about Objective-C if I want. But again, I wouldn't have that choice without RubyMotion. With it I can prioritize learning the things that help me reach my ultimate goal of improving my app quickly.

So am I saying RubyMotion is for everyone? No. It's obviously best for people with varying degrees of Ruby knowledge.

Is it perfect? No. Then again, nothing is.

Simply put: for Ruby developers, RubyMotion provides a lower barrier of entry to iOS Development. For beginners like me, it's the best tool to use if you want to get an app out quickly. For that, I'm grateful to HipByte and the community behind RubyMotion.

* I know there are other frameworks that utilize technologies such as HTML/CSS/JavaScript but I haven't seen any that deliver experiences similar to those that come from native apps. Perhaps these frameworks are the future - and I'll certainly keep an eye on them - but it's just not there yet.

** Granted, this is because my background is in Ruby and that's all I know. But still.