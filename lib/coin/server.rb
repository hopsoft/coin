require "thread"
require "singleton"
require "forwardable"

module Coin
  class Server
    extend Forwardable
    include Singleton
    def_delegators :@dict, :length

    def read(key)
      value = @dict[key]
      value = nil if value_expired?(value)
      return value[:value] if value
      nil
    end

    def write(key, value, lifetime=90)
      @mutex.synchronize do
        @dict[key] = { :value => value, :cached_at => Time.now, :lifetime => lifetime }
      end
      value
    end

    def delete(key)
      @mutex.synchronize { @dict.delete(key) }
    end

    def clear
      @dict = {}
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
        while true
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
