---
published: true
title: Refactoring Rails Views with SimplestView
subtitle: 
author: Tony Pitale
ga_id: 
created_at: 2014-01-29 11:34:50.578721 -05:00
published_at: 2014-01-29 11:34:50.580193 -05:00
layout: post
tags: ruby, rails
summary: The Rails Way to handle views is one area that quickly grows unwieldy in larger projects. I'd like to share how I use SimplestView to clean up my views, and their corresponding controllers and helpers.
---

Most of the projects I've worked with grow in similar ways. Code often ends up where it is _easiest_ to place it. For code in our Rails "Views", under `app/views`, that's either in the controller (with lots of instance variables assigned), in ApplicationHelper (shared with every view), or in the view templates themselves.

I'm going to try to address each of these scenarios, and show you how to refactor them into much simpler code, using [SimplestView](https://github.com/tpitale/simplest_view). But first, a little background.

## The Rails Way ##

In Rails, our ERB templates go under `app/views`. There is a logical structure to how they are organized. This is The Rails Way. By convention, the views for a controller `SalesController` goes inside the folder `app/views/sales`. Further, each action gets a file inside the sales folder, using the name of the action as the filename.

The tricky bit, is these Rails "Views" aren't really view objects. The ERB templates we build, are rendered inside the context of an instance of an **anonymous** class, which inherits it's rendering abilities from ActionView::Base.

But why an anonymous class? Why does Rails hide this away from us completely?

## With SimplestView ##

Now, if we set up our Rails application to use [SimplestView](https://github.com/tpitale/simplest_view#usage), we get clear, _conventional_ access to these previously hidden view classes. We give them a **name**. By convention, that name will match the action, and be placed inside a folder matching the controller name.

For our `SalesController`'s `#index` and `#show` we would have classes named `Sales::IndexView` and `Sales::ShowView` (which inherit from ActionView::Base) inside of a folder in `app/views/sales`. **Note:** SimplestView has you move your ERB into a more aptly named `app/templates` folder to keep things cleanly separated, and to give you a nice Rails-y place to put your new views.

Now that we have that out of the way, let's get into some refactorings!

## ApplicationHelper Overload ##

How often have you had to dig through an `ApplicationHelper` that simply contains _every_ single helper in the whole project? I've seen projects with an `ApplicationHelper` thousands of lines long.

Let's look at a specific method that we can refactor, and get it out of there!

<pre><code class='language-ruby'>def format_tax_rate(value)
  '%.2f%' % (value.to_f * 100)
end
</code></pre>

And it might be used in our ERB like so:

<pre><code class='language-ruby'>&lt;%= format_tax_rate(@sale.state_sales_tax) %&gt;
</code></pre>

This is some very simple code. It's a naive approach to formatting the decimal value as a percentage to two decimal places.

More importantly, it's only _really_ needed in one or two views to display a formatted sales tax rate. Why then, should it clutter up our `ApplicationHelper` in order to be shared? And, what happens when you have 10, 20, or more small methods just like this one?

With SimplestView, we can move the method to a better place. If we were to handle this in our `Sales::IndexView`, for example, we could do something like this:

<pre><code class='language-ruby'>class Sales::IndexView &lt; ActionView::Base
  def formatted_state_sales_tax
    '%.2f%' % (@sale.state_sales_tax.to_f * 100)
  end
end
</code></pre>

So, what did we do here?

1. We made our view match the conventions. For the `SalesController#index` controller and action, we'll use `Sales::IndexView` as the context for the template now found in `app/templates/sales/index.html.erb`.
2. We made a nicely named method which contains just the formatting we need.
3. We use the instance method for `@sale`, which we assigned in our controller, and is accessible to us inside of the view.

What are the benefits? Well, we get nicer encapsulation. We don't have to expose the instance variable inside of the ERB for this particular case

But, I think the best part about all of this, is we can now **easily** test, and refactor this view because it's just a Ruby class. If we have another method `formatted_county_sales_tax`, we can create a method to do the formatting. Then, if that new formatting method is used in multiple views, it's as easy as extracting a module like `SalesTaxFormattable`.

If you were to move the `format_tax_rate` you would still have to share it with the helper modules for each _controller_ that might use it. Those helper modules end up being included into the aforementioned **anonymous** view class anyway!

## Controller Assignment ##

One of the more troubling ways I've seen developers cope with growing complexity in their ERB templates has been to move calculations and logic BACK into the controller.

What started out as an action that assigns a single instance variable, baloons into methods full of `before_action` (previously `before_filter`) calls to assign and calculate many instance variables.

Let's refactor an example:

<pre><code class='language-ruby'>class SalesController &lt; ApplicationController
  def show
    @sale = Sale.find(params[:id])
    @purchase_count = @sale.purchases.count
  end
end
</code></pre>

Now, we can output both data about our `@sale`, but we can also output our `@purchase_count` number, too.

Instead, let's do it with SimplestView.

<pre><code class='language-ruby'>class Sales::ShowView &lt; ActionView::Base
  def purchase_count
    @purchase_count ||= @sale.purchases.count
  end
end
</code></pre>

Now, we can still output our `purchase_count` in our template, without cluttering our controller!

## ERB Templates ##

By now, it may be clear what I'm going to say. But, I'll say it anyway.

Extraneous logic in your ERB templates is _very_ likely to be a code smell. Extensive branching logic, local variable assignment, etc. Time to get it out!

Inside of our `SalesController#show` action, we'll likely render the template found in `show.html.erb`. It might have some code like:

<pre><code class='language-ruby'>&lt;% @sale.starts_on &lt;= Date.today &amp;&amp; @sale.ends_on > Date.today %&gt;
  On Sale!
&lt;% else %&gt;
  Sale Starts On: &lt;%= @sale.starts_on.strftime("%B %d, %Y") %&gt;
&lt;% end %&gt;
</code></pre>

There are two things in this code that we really don't need. Both the `if` conditional and the date formatting code can be encapsulated in our `Sales::ShowView`.

<pre><code class='language-ruby'>class Sales::ShowView &lt; ActionView::Base
  def active_sale?
    @sale.starts_on &lt;= Date.today &amp;&amp; @sale.ends_on > Date.today
  end

  def formatted_start_date
    @sale.starts_on.strftime("%B %d, %Y")
  end
end
</code></pre>

This is probably my favorite refactoring. And, it is likely to be the one you will use on a regular basis.

## But Why? ##

The benefits of these changes might not be the biggest pain you feel in your code, day to day. But together, all of the little changes you get to make,  the added ease of refactoring, and the extra convention, make it a whole lot easier to write well-factored, maintainable code, every day.

I'm using [SimplestView](https://github.com/tpitale/simplest_view) daily, in as many of my projects as possible. Not because the code I already have is horrendous, and not because there are no alternatives to refactor and clean up my code. I'm using it because it enables functionality in Rails that should be available already, and it gives me the conventions I kept searching for.

If SimplestView doesn't strike your fancy, you can go the decorator route with the fantastic [Draper](https://github.com/drapergem/draper). Both Draper and SimplestView accomplish very similar things. Regardless, you should try using one of them, and see how it helps you clean up your code.

