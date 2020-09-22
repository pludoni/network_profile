require "network_profile/version"
require 'network_profile/extractor'
require 'network_profile/extractors/default_profile'
require 'active_support/core_ext/module/attribute_accessors'

module NetworkProfile
  class Error < StandardError; end

  mattr_accessor :headers, :github_api_key

  self.headers = {
    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language' => 'de,en-US;q=0.7,en;q=0.3',
    'Referer' => 'https://www.google.com',
    'DNT' => '1',
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:73.0) Gecko/20100101 Firefox/73.0',
  }
  self.github_api_key = nil

  def self.parse(link, include_fallback_custom: false)
    NetworkProfile::DefaultProfile.parse(link, include_fallback_custom: include_fallback_custom)
  end
end
