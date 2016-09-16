require 'moneta'

module Urlcheck
  class Cache
    def initialize(*moneta_args)
      @store = Moneta.new(*moneta_args)
    end

    def format_key(key)
      "urlcheck:#{key}"
    end

    def get(key, timestamp: nil, at_least: nil)
      key = format_key(key)

      if entry = @store[key]
        if !stale?(entry['timestamp'], at_least)
          entry['value']
        end
      end
    end

    def stale?(cached, at_least)
      return false unless at_least
      return true unless cached
      cached < at_least
    end

    def set(key, value, timestamp: nil)
      key = format_key(key)

      @store[key] = {'value' => value, 'timestamp' => timestamp }
    end

    def write_through(key, timestamp: nil, at_least: nil)
      if entry = get(key, at_least: at_least)
        entry
      else
        cache_or_not, result = yield

        if cache_or_not == :cache
          set key, result, timestamp: timestamp
        end

        result
      end
    end
  end
end
