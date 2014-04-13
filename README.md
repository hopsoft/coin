# Coin

[![Build Status](https://travis-ci.org/hopsoft/coin.png)](https://travis-ci.org/hopsoft/coin)
[![Dependency Status](https://gemnasium.com/hopsoft/coin.png)](https://gemnasium.com/hopsoft/coin)
[![Code Climate](https://codeclimate.com/github/hopsoft/coin.png)](https://codeclimate.com/github/hopsoft/coin)

## Memcached? We don't need no stinking Memcached. <sup><a href="#cultural-references">1</a></sup>

Well... you might depending upon your specific needs,
but have a look at Coin before you reach for the sledgehammer.

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

# read and/or assign a default value in a single atomic step
Coin.read(:bar) { true } # => true

# write data with an explicit expiration (in seconds)
# this example expires in 5 seconds (default is 300)
Coin.write :bar, true, 5
sleep 5
Coin.read :bar # => nil

# delete an entry
Coin.write :bar, true
Coin.delete :bar
Coin.read :bar # => nil

# read and delete in a single atomic step
Coin.write :bar, true
Coin.read_and_delete :bar # => true
Coin.read :bar # => nil

# read and update in a single atomic step
Coin.write :bar, true
Coin.read_and_update :bar do |value|
  !value
end
Coin.read :bar # => false

# determine how many items are in the cache
10.times do |i|
  Coin.write "key#{i}", true
end
Coin.length # => 10

# clear the cache
Coin.clear
Coin.length # => 0
```

## Deep Cuts

Coin automatically starts a DRb server that hosts the Coin::Vault.
You can take control of this behavior if needed.

```ruby
require "coin"

# configure the port that the DRb server runs on (default is 8955)
Coin.port = 8080

# configure the URI that the DRb server runs on (defaults to druby://localhost:PORT)
Coin.uri = "druby://10.0.0.100:8080"

# access the DRb server exposing Coin::Vault
Coin.server # => #<Coin::Vault:0x007fe182852e18>

# determine if the server is running
Coin.server_running? # => true

# determine the pid of the server process
Coin.pid # => "63299"

# stop the server
Coin.stop_server # => true

# start the server
Coin.start_server # => true

# start the server forcing a restart if the server is already running
Coin.start_server true # => true
```

Coin also supports configuring a remote server.
Allowing a single Coin server to service multiple machines.

```ruby
Coin.remote_uri = "druby://192.168.0.12:8808"
```

Want interoperability with other languages? Check out
[CoinRack](https://github.com/hopsoft/coin_rack) which provides
a REST API on top of Coin.

## Best Practices

All objects stored with Coin must be able to marshal.

Its generally a good idea to store only the most basic objects.
For example:

* Boolean
* String
* Number

Its possible to store more complex objects such as:

* Array
* Hash

Just be sure to limit the keys & values to basic types.

## Run the Tests

```bash
$ gem install coin
$ gem unpack coin
$ cd coin-VERSION
$ bundle
$ mt
```

## Notes

Coin's default behavior launches a single DRb server that provides
shared access across all processes on a **single machine**.
You need to configure `Coin.remote_uri` if you want Coin to connect to a
DRb server on another machine.

![Coin Diagram](https://raw.github.com/hopsoft/coin/gh-pages/assets/images/coin.png)

## Cultural References

1. "Badges? We don't need no stinking badges!" - from Mel Brooks' film [Blazing Saddles](http://en.wikipedia.org/wiki/Stinking_badges)
