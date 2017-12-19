RespondToFaster :rocket:
========================

[![Gem Version](https://badge.fury.io/rb/respond_to_faster.svg)][gem]
[![Build Status](https://travis-ci.org/shioyama/respond_to_faster.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/shioyama/respond_to_faster.svg)][gemnasium]

[gem]: https://rubygems.org/gems/respond_to_faster
[travis]: https://travis-ci.org/shioyama/respond_to_faster
[gemnasium]: https://gemnasium.com/shioyama/respond_to_faster

Speed up method response times on results from custom aliased ActiveRecord
queries.

## Usage

Just add the gem to your Gemfile:

```ruby
gem 'respond_to_faster', '~> 0.1.0'
```

That's it! Read on to learn about what RespondToFaster is doing under the hood
(or checkout the source code, it's only 20 lines long!)

## Background

Suppose you have a query with some custom SQL, like this (taken from the
[ActiveRecord Querying documentation](http://guides.rubyonrails.org/active_record_querying.html#group)):

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").group("date(created_at)")
```

This query will group orders by date, with each date result responding to the
aliases `ordered_date` and `total_price`. So if `order` is the first result
returned, this will work:

```ruby
order.ordered_date
#=> Thu, 14 Dec 2017
order.total_price
#=> 20.98
```

This is nice, but are those really methods? Let's have a look:

```ruby
order.method(:ordered_date)
#=> NameError: undefined method `ordered_date' for class `#<Class:0x00559df3a8ef30>'
```

That's strange! No method. So how is the object responding to the
`ordered_date` message?

As usual, Rails is doing some magic under the hood. You can find that magic
documented in the [inline
docs](https://github.com/rails/rails/blob/fd1304d2aaf5e21df0aac2e8e3f7becdaad15b19/activemodel/lib/active_model/attribute_methods.rb#L415-L420)
for `ActiveModel::AttributeMethods`, where there is the somewhat cryptic message:

> Allows access to the object attributes, which are held in the hash
> returned by <tt>attributes</tt>, as though they were first-class
> methods. So a <tt>Person</tt> class with a <tt>name</tt> attribute can for example use
> <tt>Person#name</tt> and <tt>Person#name=</tt> and never directly use
> the attributes hash -- except for multiple assignments with
> <tt>ActiveRecord::Base#attributes=</tt>.

This inline comment dates back to the [very first Rails commit by @dhh in
2004](https://github.com/rails/rails/commit/db045dbbf60b53dbe013ef25554fd013baf88134).

What the code (now in ActiveModel, previously in ActiveRecord) actually does is
to override `respond_to?` and `method_missing` to check if a given method call
matches a key in the `attributes` hash of the model. If there's a match,
ActiveModel "dispatches" to an attribute handler, which returns the result.

Which is all fine and good, but **method_missing is slow as molasses**. You never
really want to be relying on it to return results unless you have no
alternative.

## What this gem does

So what this gem does is to *remove these overrides*, which have been around
since the dawn of Ruby on Rails. Not just tweak them, or override them, but
**remove them**.

Here is the code that does this, just two lines:

```ruby
ActiveModel::AttributeMethods.send(:remove_method, :respond_to?)
ActiveModel::AttributeMethods.send(:remove_method, :method_missing)
```

For the vast majority of cases, *this will have no impact on your ActiveRecord
objects*. AR has grown over the years to the point where most attribute methods
are defined, so these fallbacks are not necessary.

The one exception is the example earlier with the custom aliased query. In this
case, depending on the query, some custom attributes are needed on the objects
returned, and ActiveRecord still relies on this (very slow) mechanism to make
the magic work.

But this is a high price to pay for some simple magic. This gem instead
*defines the methods* on the singleton class of the objects returned, so that
you never need to go to `method_missing`. This makes things **much faster**, as
much as 5-10 times faster.

## Caveats

If you don't use any custom querying with aliases like the one above, this gem
might not do much for you. It should make `respond_to?` a bit faster, but you
may not even notice that.

However, if you've got some crazy heavy SQL logic somewhere deep in your
application, and you're finding it takes forever, give this gem a shot and tell
me what you find! I'd like to get this eventually merged into ActiveRecord so
I'd like to know about any issues you encounter in your application.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/shioyama/respond_to_faster. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RespondToFaster project’s codebases, issue
trackers, chat rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/shioyama/respond_to_faster/blob/master/CODE_OF_CONDUCT.md).
