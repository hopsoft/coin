require "thread"
require "singleton"
require "forwardable"
require "monitor"

module Coin
  class Vault
    extend Forwardable
    include Singleton
    include MonitorMixin
    def_delegators :@dict, :length

    def read(key)
      value = @dict[key]
      value = nil if value && value_expired?(value)
      return value[:value] if value
      nil
    end

    def write(key, value, lifetime=300)
      synchronize do
        @dict[key] = { :value => value, :cached_at => Time.now, :lifetime => lifetime }
      end
      value
    end

    def delete(key)
      synchronize { @dict.delete(key) }
    end

    def read_and_delete(key)
      value = nil
      synchronize do
        value = read(key)
        @dict.delete(key)
      end
      value
    end

    def read_and_write(key, lifetime=300)
      orig_value = nil
      value = nil
      synchronize do
        orig_value = read(key)
        value = yield(orig_value)
        write key, value, lifetime
      end
      [orig_value, value]
    end

    def clear
      synchronize { @dict = {} }
    end

    def ok?
      true
    end

    protected

    def initialize
      super
      @dict = {}
      start_sweeper
      self
    end

    def start_sweeper
      Thread.new do
        loop do
          sleep 60
          sweep
        end
      end
    end

    def sweep
      now = Time.now
      @dict.each do |key, value|
        delete(key) if value_expired?(value)
      end
    end

    def value_expired?(value)
      Time.now - value[:cached_at] > value[:lifetime]
    end

  end
end
