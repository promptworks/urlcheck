require 'typhoeus'

require_relative 'cache'

module Urlcheck
  class Checker
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"
    }

    attr_accessor :http, :cache

    def initialize(http: Typhoeus, cache: Urlcheck::Cache.new(:Memory))
      self.http = http
      self.cache = cache
    end

    def check(url, timestamp: nil, at_least: nil)
      cache.write_through url, timestamp: timestamp, at_least: at_least do
        result = fetch(url, http: http)

        cache_or_not = result[:exists] ? :cache : :dont_cache

        [cache_or_not, result]
      end
    end

    def exists?(code)
      (200..299).include?(code) && code != 202
    end

    def fetch(url, http: Typhoeus)
      response = http.get(url, followlocation: true, headers: HEADERS)
      code = response.code

      { url: url, code: code, exists: exists?(code) }
    rescue Errno::ENOENT
      { url: url, message: 'Cannot find server' }
    end
  end
end
