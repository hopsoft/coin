require "thread"
require "singleton"
require "forwardable"

module Coin
  class Vault
    extend Forwardable
    include Singleton
    def_delegators :@dict, :length

    def read(key)
      value = @dict[key]
      value = nil if value && value_expired?(value)
      return value[:value] if value
      nil
    end

    def read_and_delete(key)
      value = nil
      @mutex.synchronize do
        value = read(key)
        @dict.delete(key)
      end
      value
    end

    def write(key, value, lifetime=300)
      @mutex.synchronize do
        @dict[key] = { :value => value, :cached_at => Time.now, :lifetime => lifetime }
      end
      value
    end

    def delete(key)
      @mutex.synchronize { @dict.delete(key) }
    end

    def clear
      @mutex.synchronize { @dict = {} }
    end

    def ok?
      true
    end

    protected

    def initialize
      @mutex = Mutex.new
      @dict = {}
      start_sweeper
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
