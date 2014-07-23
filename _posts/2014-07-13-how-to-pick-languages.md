---
published: true
title: how-to-pick-languages
subtitle: 
author: Adam Keys
ga_id: 
created_at: 2014-07-13 20:03:43.439240 -05:00
published_at: 2014-07-13 20:03:43.439350 -05:00
layout: post
tags:
summary:
---

# Ideas for choosing your next language foray

My relationship with programming languages is sometimes problematic. You see, it's quite easy for me to see that the grass must _clearly_ be greener on the other side of the language fence. Thus, I spend a lot of time doing anything from a light tinker to a full-blown deep dive into new or interesting languages.

I'm a programming language aficionado. More often than not, a dilettante.

That confessional aside, I _do_ have guidelines that help me decide when to read over language docs looking for interesting ideas, when to tinker with it if I get "the urge", and when to do a full-blown weekend dive into a language.

**WARNING** this is for personal use only. Almost none of these guidelines hold water when it comes time to decide to deploy software to production.

* * *

My favorite reason to dive into a language is **the creator has a very good taste in solving problems with computers or thinking about how developers think about writing programs**. Though they sit on very different points in the language spectrum, [Rich Hickey's](http://www.infoq.com/presentations/Simple-Made-Easy) ([Clojure](http://clojure.org)) and [Martin Odersky's](http://www.se-radio.net/2007/07/episode-62-martin-odersky-on-scala/) ([Scala](http://www.scala-lang.org)) both have very compelling ideas about how to design a programming language for developers such that it magnifies a developer's ability to think about solving problems with computers. Other times, the intrigue of a language designer's philosophy and work make it worth looking into a language even if I never intend to use it. I checked out [Rasmus Andersson's](http://rsms.me) [Move](http://movelang.org) solely on the strength of the rest of his work.

**Novelty of solution** is an interesting angle. Some languages solve a boring problem with a novel approach. For example, [CoffeeScript](http://coffeescript.org) was the first language to treat JavaScript as a boring, lower-level target and layer a principled, tidier language on top of it via a translation layer. Building on top of that, I recently came across [Iced CoffeeScript](http://maxtaco.github.io/coffee-script/), which takes a problem that is new to many developers, confusing callback hierarchies, and layers some CoffeeScript syntax over rewriting the nested code as linear defer/await structures. [Elixir](http://elixir-lang.org) is trending lately, and falls under the same scope, though it's target is the Erlang ecosystem.

Languages with **challenging, satisfying, or interesting principles** are a source of intrigue. [Haskell's](http://learnyouahaskell.com) principles of *extremely* pure functional programming and type safety are a real puzzle if you're coming from Ruby, which allows all manners of things Haskell outright forbids. Clojure's principles, taken as a whole, can be very satisfying: write small functions passing immutable data structures, with very explicit handling of program state to compose programs that eschew complexity in favor of simplicity due to boundaries. [Erlang's](http://learnyousomeerlang.com) emergent qualities are very interesting: use functions, pattern matching, and actors to implement reliable distributed systems. I saw a language that was all about making unit conversion, e.g. feet to meters, explicit in the language. Point is, some languages are fun playing around with simply to bend your brain in weird ways.

Languages that **make previously inaccessible application domains simple** can be a real ego boost. Right now, [Swift](https://developer.apple.com/swift/blog/) is attracting a lot of eyeballs as it makes developing for Apple devices far simpler than it has been in the past. In the same way, Clojure makes Lisp a little easier, Erlang makes distributed systems a slightly less enigmatic, and [Go](http://golang.org) makes systems programming less intimidating.

A language with **a healthy culture is worth its weight in gold**. If the values of the people and code in a language don't align well, you'll have a bad time. If they fit well within your own, you're going to have a ton of fun. This is the most subjective of all parameters. I find the principles around Go and Clojure really intriguing and thus find them really interesting. I'm less jazzed about Scala or C++, so I "read into them" a lot less often.

Some languages are worth considering solely on the **strength of the implementation**. [Lua](http://www.lua.org) is highly regarded for its simple of design and [the modernity of its runtime](http://luaforge.net/docman/83/98/ANoFrillsIntroToLua51VMInstructions.pdf) given the tradeoffs required in a tool designed for embedding in larger software as a scripting language. Likewise, V8 and the Hotspot JIT compiler are well regarded technologies that make considering JavaScript and Java a rationale choice despite the shortcomings of those two languages.

Finally, **not every language is cut out for an enthusiastic tinker**. I'm likely to skip languages that are highly experimental, highly mathematical, come from boring vendors, or are too similar to languages I already know or use. That crosses languages like Seph, Agda, or Python off my list.

* * *

There's half a dozen ideas to give yourself permission and treat yourself to learning a new language. Of course, the old standby excuses are pretty good too. Learning _any_ new programming language expands your brain. Every language you learn gives you more vocabulary to solve problems, no matter what languages you use on a day-to-day basis.

Teaching yourself a new language is a winning proposition, you only have to decide where to start. And then learn the language. But sometimes the decision is harder than the learning!

Hopefully my guidelines, and perhaps some of the languages that satisfy them, will help you next time you get that itch to explore a new programming language.
