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
to create a simple in memory caching server that addresses many of the same needs as Memcached
and other similar solutions.

## Quick Start

Installation

```bash
$ gem install coin
```

Basic Usage

```ruby
require "coin"
Coin.write :foo, true
Coin.read :foo # => true
```

## Next Steps

Examples of more advanced usage.

```ruby
require "coin"

# read and/or assign a default value in a single step
Coin.read(:bar) { true } # => true

# write data with an explicit expiration (in seconds)
# this example expires in 5 seconds (default is 300)
Coin.write :bar, true, 5
sleep 5
Coin.read :bar # => nil

# read and delete in a single step
Coin.write :bar, true
Coin.read_and_delete :bar # => true
Coin.read :bar # => nil

# delete a key
Coin.write :bar, true
Coin.delete :bar
Coin.read :bar # => nil

# determine how many items are in the cache
10.times do |i|
  Coin.write "key#{i}", true
end
Coin.length # => 10

# clear the cache
Coin.clear
Coin.length # => 0
```
