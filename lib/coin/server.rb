require "thread"
require "singleton"

module Coin
  class Server
    include Singleton

    def read(key)
      value = @dict[key]
      return value[:value] if value
      nil
    end

    def write(key, value, lifetime=90)
      @mutex.synchronize do
        @dict[key] = {:value => value, :cached_at => Time.now, :lifetime => lifetime}
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

    private

    def initialize
      @mutex = Mutex.new
      @dict = {}
      start_sweeper
    end

    def start_sweeper
      Thread.new do
        while true
          sleep 1
          sweep
        end
      end
    end

    def sweep
      now = Time.now
      @dict.each do |key, value|
        delete(key) if now - value[:cached_at] > value[:lifetime]
      end
    end

  end
end
