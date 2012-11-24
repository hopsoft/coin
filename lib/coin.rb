require File.join(File.dirname(__FILE__), "coin", "version")
require "singleton"

# A very simple in memory caching utility.
class Coin
  include Singleton

  # Reads an item from the cache.
  # @return [Object] Returns the found object or nil.
  def read(key)
    @read_count += 1
    result = @dict[key]
    clean if should_clean?
    if result
      expired = Time.now - result[:cached_at] > result[:lifetime]
      if expired
        @dict.delete(key)
      else
        return result[:value]
      end
    end
    nil
  end

  # Writes an item to the cache.
  # @param [Object] key The cache key to use.
  # @param [Object] value The value to cache.
  # @param [Integer] lifetime The number of seconds to keep the key/value in the cache. Defaults to 90.
  # @return [Object] Returns the passed value.
  def write(key, value, lifetime=90)
    @dict[key] = {:value => value, :cached_at => Time.now, :lifetime => lifetime}
    value
  end

  # Removes expired items.
  def clean
    now = Time.now
    @dict.each do |key, value|
      @dict.delete(key) if now - value[:cached_at] > value[:lifetime]
    end
  end

  # Clears the cache.
  def clear
    @dict = {}
    @read_count = 0
  end

  private

  def initialize
    @dict = {}
    @clean_threshold = 5000
    @read_count = 0
  end

  def should_clean?
    @read_count % @clean_threshold == 0
  end

end
