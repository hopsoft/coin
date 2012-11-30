# Coin

## Memcached? We don't need no stinking Memcached.

... Well, you might depending upon your specific needs.
But be sure to have a look at Coin before you reach for the sledgehammer.

Coin is an absurdly simple in memory object caching system written in Ruby.

## Why Coin?

* No configuration required
* No added complexity to your stack
* Small footprint (under 200 lines)
* Simple API

Coin uses [Distributed Ruby (DRb)](http://pragprog.com/book/sidruby/the-druby-book)
to create a simple in memory caching server that fills many of the same needs as Memcached
and other similar solutions.

## Quick Start

```bash
$ gem install coin
```

```ruby
require "coin"

Coin.write :foo, true
Coin.read :foo # => true
```
