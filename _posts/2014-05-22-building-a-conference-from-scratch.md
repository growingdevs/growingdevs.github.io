---
published: false
title: Building a Conference From Scratch
subtitle: 
author: Jeremy Carbaugh
created_at: 2014-05-22 22:06:31.188414 -04:00
published_at: 2014-05-22 22:06:31.189649 -04:00
layout: post
tags: python, ios, diy
summary: Running your own conference provides the opportunity to create fun projects from scratch. Running TransparencyCamp, we've created a lot of great software at the Sunlight Foundation, but we've also duplicated a lot of existing work.
---

Anyone who knows me well will tell you that I have a terrible habit of reinventing the wheel. It can get [really, really bad](http://sunlightfoundation.com/blog/2011/11/02/on-cms-diy/) at times. I know there is a lot of great software out there, but there is always the smallest little thing that keeps it from being perfect. I know I can do better! So imagine the itch I get when someone says "Hey, we have to run a conference."

[TransparencyCamp](http://transparencycamp.org/) is an open government unconference run by my employer, the [Sunlight Foundation](http://sunlightfoundation.com/). We started TransparencyCamp in 2009 with just under 100 attendees. It was a scrappy little event, with most of us having very little experience running a conference. On May 30-31, 2014, we'll be hosting over *550 people from across the world* at TransparencyCamp 2013.

As the conference has grown, we've had the chance to build numerous projects that help us run the event. Sure, we could have used existing software to do it, but it's way more fun to build our own.

## The Badges and Registration

In previous years we used [Eventbrite](http://eventbrite.com) for registration and ticketing. It was a great system; they even provide a mobile app that can be used at the check-in desk to scan badges. Never wanting to settle for good enough, we figured out the format of the data stored in the Eventbrite-generated barcodes and encoded our own as QR codes that were printed on the badges. These badges could still be read by the app provided by Eventbrite, but when used in conjunction with the Eventbrite API, we could manage the process using our own systems.

This year we've gone with a completely homegrown registration and ticketing system writen in [Python](https://www.python.org/) and [Django](https://www.djangoproject.com/). It uses [Braintree](https://www.braintreepayments.com/) for processing payments, sends email with [Postmark](https://postmarkapp.com), and has an API for accessing ticket information. The system also takes care of generating all of the QR codes that are printed on the badges.

Having all of the ticket information in our own system allows us to tie in other aspects of the event. We have several food trucks available for lunch (covered by the price of a ticket) and will have staff at each truck scanning the QR code on attendee badges when they get their food. This isn't just to make sure people only eat one meal, it will also provide us with valuable data about which trucks were the most popular and how fast each truck was able to serve customers. We'll be displaying this information in real-time at the event.

## The Schedule

<figure>
<a href="https://www.flickr.com/photos/sunlightfoundation/8717344451" title="An attentive crowd in front of &quot;The Wall&quot; by sunlightfoundation, on Flickr"><img src="https://farm8.staticflickr.com/7422/8717344451_bb0ccff6f2.jpg" width="500" height="333" alt="An attentive crowd in front of &quot;The Wall&quot;"></a>
<figcaption>An attentive crowd in front of &quot;The Wall&quot; by sunlightfoundation</figcaption>
</figure>

What would an unconference be without a giant wall for schedule making? Until last year we used a paper-based wall where people would write session information on cards and tape them to the wall. We decided to try something different in 2013 (partially due to the venue not allowing tape on the walls) and go completely digital. Sessions were submitted via laptops or paper and entered into a database. This database powered both the web site and a giant HTML calendar view that was cast onto the wall using three short throw projectors.

We're moving back to paper this year due to readability issues with the digital wall (distance, text size, clarity, etc.), but sessions will still be submitted electronically. Cards for each session will be printed and hung on the wall by staff.

## The Counselors

Who wants to come to a conference and see the staff fumbling through stacks of papers or have to stand around while a staff member that can help solve your problem is located?

<img src="http://assets.sunlightfoundation.com.s3.amazonaws.com/CampCounselor.png" style="float: right; margin: 0 0 1em 1em;">

Almost everything staff need to do at TransparencyCamp is handled by a custom iOS app, Camp Counselor. This includes:

* scanning badges to check-in attendees
* viewing check-in stats and other important day-of information
* scanning badges to "rent" display adapters and other equipment
* marking equipment as returned or sending a polite email to people that have run off with something
* scanning badges (lots of scanning) to redeem lunch at food trucks
* scanning badges to register attendees for API keys

All of this information is stored on a central server, Lodge, that has a simple JSON API. The Lodge is a Python web app written in [Flask](http://flask.pocoo.org/) and hosted on [Heroku](http://heroku.com). The iOS app itself is a small client to the API using [AFNetworking](http://afnetworking.org) for making calls to the server.

We distribute the app to staff devices via [TestFlight](http://testflightapp.com). If an emergency fix needs to be pushed out, TestFlight can force people to upgrade, ensuring that everyone is using the latest version.


## The Other Stuff

<figure>
<a href="https://www.flickr.com/photos/bytemarks/6980599906" title="Transparency Camp 2012 by Burt Lum, on Flickr"><img src="https://farm9.staticflickr.com/8148/6980599906_146e560058.jpg" width="500" height="374" alt="Transparency Camp 2012"></a>
<figcaption>Transparency Camp 2012 by Burt Lum</figcaption>
</figure>

Since it's the small details that really make a difference, we've built out a number of other interesting things:

* HTML-based information screens placed around the event that show current schedule information
* HTML-based slideshows shown on screens that cycle through tweets and Instagrams from the event
* live-streaming of keynote talks
* a responsive web site, optimized for day-of use on mobile
* an interactive SMS interface to the schedule

---

There is no doubt that we could have run TransparencyCamp throughout the years without spending all of this time on custom development. It would have been a perfectly fine conference, but we don't want to settle for "fine" at Sunlight. The extra effort that we put into the systems and the experience sets the tone for the event. It shows that we care about the little details. It shows that we seek to inspire. It shows that TransparencyCamp is unlike any other conference you've been to.

It is important to understand all of the downsides that come along with the decision to embark on your own path and reinvent the wheel. It's not something that should be taken lightly. However, if done with understanding and purpose, extreme DIY can yield fantastic (and super fun) results.

*Source code for the Camp Counselor iOS app and Lodge server will be made available shortly after TransparencyCamp 2014 on the [Sunlight Labs GitHub account](https://github.com/sunlightlabs). The TransparencyCamp site, registration, and scheduling systems have [already been published](https://github.com/sunlightlabs/tcamp). These projects, like all good software, are available under the BSD license.*