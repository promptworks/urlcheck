require 'spec_helper'

describe Urlcheck do
  it 'has a version number' do
    expect(Urlcheck::VERSION).not_to be nil
  end

  def url_with_status(status)
    httpbin("status/#{status}")
  end

  def httpbin(path)
    "http://httpbin.org/#{path}"
  end

  def check(url)
    checker.check(url)
  end

  let(:checker) do
    Urlcheck::Checker.new
  end

  it 'marks successful codes as existing' do
    [200, 201, 203..208, 266].flat_map(&method(:Array)).each do |status|
      result = check(url_with_status(status))

      expect(result[:code]).to eq status
      expect(result[:exists]).to be true
    end
  end

  it 'marks unsuccessful codes as not existing' do
    [0, 400..431, 500..511, 520..526, 999].flat_map(&method(:Array)).each do |status|
      result = check(url_with_status(status))

      expect(result[:code]).to eq status
      expect(result[:exists]).to be false
    end
  end

  describe 'a redirect' do
    specify "to a success code is a success" do
      result = check(httpbin("redirect/2"))

      expect(result[:code]).to eq 200
      expect(result[:exists]).to be true
    end

    specify "to a failure code is a failure" do
      error_url = url_with_status(400)
      result = check(httpbin("redirect-to?url=#{error_url}"))

      expect(result[:code]).to eq 400
      expect(result[:exists]).to be false
    end
  end

  it "a host that does not exist returns 0" do
    result = check("http://localhost:2")

    expect(result[:code]).to eq 0
  end

  it "caches successful results" do
    url = url_with_status(200)

    original_result = check(url)

    checker.http = double(:dont_use_this)
    cached_result = check(url)

    expect(original_result).to eq cached_result
  end

  it "does not cache unsuccessful results" do
    bad_url = url_with_status(400)
    http_double = double(:http_double, get: double(:response, code: 666))

    check(bad_url)

    checker.http = http_double
    expect(check(bad_url)[:code]).to eq 666
  end

  it "uses a User Agent that does not set off alarms for sites" do
    %w[
      http://servicevirtualization.com/sv-101/
      https://2013.nashville.wordcamp.org/
    ].each do |url|
      expect(check(url)[:exists]).to be true
    end

  end
end
