require "network_profile/version"
require 'network_profile/extractor'
require 'network_profile/extractors/default_profile'
require 'active_support/core_ext/module/attribute_accessors'

module NetworkProfile
  class Error < StandardError; end

  mattr_accessor :headers, :github_api_key, :proxy, :proxy_user_pass

  self.headers = {
    "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "Accept-Language"=>"de",
    "User-Agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36",
    "Referer" => "https://www.google.com",
    "Cache-Control"=>"max-age=0"
  }
  self.github_api_key = nil

  def self.parse(link, include_fallback_custom: false)
    NetworkProfile::DefaultProfile.parse(link, include_fallback_custom: include_fallback_custom)
  end
end
