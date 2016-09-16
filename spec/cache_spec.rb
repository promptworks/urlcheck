require 'spec_helper'

describe Urlcheck::Cache do
  let(:cache) do
    Urlcheck::Cache.new(:Memory)
  end

  it "sets values" do
    cache.set "key", "value"
    cache.set "other key", "other value"

    expect(cache.get("key")).to eq "value"
    expect(cache.get("other key")).to eq "other value"
  end

  it "sets an existing value" do
    cache.set "key", "old value"
    cache.set "key", "new value"

    expect(cache.get("key")).to eq "new value"
  end

  it "get unset value" do
    expect(cache.get("key")).to be nil
  end

  it "get when the cached timestamp is younger than acceptable" do
    cache.set "key", "value", timestamp: 2016
    expect(cache.get("key", at_least: 2015)).to eq "value"
  end

  it "get when the cached timestamp is the same as the acceptable timestamp" do
    cache.set "key", "value", timestamp: 2016
    expect(cache.get("key", at_least: 2016)).to eq "value"
  end

  it "get when the cached timestamp is older than acceptable" do
    cache.set "key", "value", timestamp: 2015
    expect(cache.get("key", at_least: 2016)).to be nil
  end

  it "get when the cached timestamp was not set and the acceptable timestamp is not set" do
    cache.set "key", "value"
    expect(cache.get("key")).to eq "value"
  end

  it "get when the cached timestamp was not set but the acceptable timestamp is" do
    cache.set "key", "value"
    expect(cache.get("key", at_least: 2016)).to be nil
  end

  it "write_through obeys timestamps when setting" do
    cache.write_through "key", timestamp: 2016 do
      [:cache, "value"]
    end

    expect(cache.get("key", at_least: 2015)).to eq "value"
    expect(cache.get("key", at_least: 2017)).to be nil
  end

  it "write_through obeys timestamps when getting and the cache is fresh" do
    cache.set "key", "original value", timestamp: 2015

    result = cache.write_through "key", timestamp: 2016, at_least: 2014 do
      [:cache, "new value"]
    end
    expect(result).to eq "original value"
  end

  it "write_through obeys timestamps when getting and the cache is stale" do
    cache.set "key", "original value", timestamp: 2015

    result = cache.write_through "key", timestamp: 2016, at_least: 2016 do
      [:cache, "new value"]
    end
    expect(result).to eq "new value"
  end

  it "write_through updates timestamps, too, when overwriting" do
    cache.set "key", "original value", timestamp: 2015

    cache.write_through "key", timestamp: 2016, at_least: 2016 do
      [:cache, "new value"]
    end

    expect(cache.get("key")).to eq "new value"
  end

  it "writes through, caching the value" do
    result = cache.write_through "key" do
      [:cache, "value"]
    end

    expect(result).to eq "value"
    expect(cache.get("key")).to eq "value"
  end

  it "writes through, not caching the value" do
    result = cache.write_through "key" do
      [:dont_cache, "value"]
    end
    expect(result).to eq "value"
    expect(cache.get("key")).to be nil
  end

  it "writes through, not executing function if key is already set" do
    cache.set "key", "original value"
    result = cache.write_through "key" do
      raise "SHOULD NOT RUN"
    end
    expect(result).to eq "original value"
  end
end
