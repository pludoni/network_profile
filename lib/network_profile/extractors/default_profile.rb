require 'rdf/microdata'
require 'active_support/descendants_tracker'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'nokogiri'
require 'typhoeus'

module NetworkProfile
  class DefaultProfile
    include ActiveSupport::DescendantsTracker

    class << self
      attr_accessor :mdi_icon
      attr_accessor :headers
    end

    def self.auto_extractor_link_types
      [
        NetworkProfile::GithubProfile,
        NetworkProfile::GithubProject,
        NetworkProfile::LinkedinProfile,
        NetworkProfile::InstagramProfile,
        NetworkProfile::XingProfile,
        NetworkProfile::ResearchgateProfile,
        NetworkProfile::UpworkProfile,
        NetworkProfile::FacebookProfile,
        NetworkProfile::StackoverflowProfile,
      ].freeze
    end

    def self.all_types
      auto_extractor_link_types + [NetworkProfile::Custom]
    end

    def self.parse(link, include_fallback_custom: false)
      link_type = (include_fallback_custom ? all_types : auto_extractor_link_types).find { |i| i.handle?(link) }
      if link_type
        link_type.new(link.strip).data
      end
    end

    def initialize(link)
      @link = link
    end

    def image
      img = doc.at('meta[property=og\:image]')&.[]('content')
      if img && img[%r{^/\w+}]
        img = URI.join(@link, img).to_s
      end
      img
    end

    def title
      doc.at('title')&.text
    end

    def text
      doc.at('meta[property=og\:description]')&.[]('content') || doc.at('meta[name=description]')&.[]('content')
    end

    def data
      {
        site_icon: self.class.mdi_icon,
        link: @link,
        title: title,
        text: text,
        image: image,
        type: self.class.name.underscore.split('/').last
      }.merge(extra_data)
    end

    def extra_data
      {}
    end

    private

    def response
      @response ||= Typhoeus.get(@link, headers: NetworkProfile.headers, followlocation: true)
    end

    def doc
      @doc ||= Nokogiri.parse(response.body)
    end

    def json_ld
      @json_ld ||=
        begin
          ld = doc.search('script[type*=ld]').first&.text
          if ld
            JSON.parse(ld)
          else
            {}
          end
        end
    end

    def rdf
      @rdf ||= map_rdf(
        RDF::Microdata::Reader.new(response.body).to_h
      )
    end

    def map_rdf(tree)
      tree.
        transform_keys { |v| map_rdf_value(v) }.
        transform_values { |v| map_rdf_value(v) }
    end

    def map_rdf_value(value)
      case value
      when RDF::Vocabulary::Term then value.fragment
      when RDF::URI then value.to_base
      when RDF::Node then value.id
      when RDF::Literal then value.value
      when Hash then map_rdf(value)
      when Array then value.map { |i| map_rdf_value(i) }
      else
        value
      end
    end
  end
end

require_relative './custom'
require_relative './github_profile'
require_relative './github_project'
require_relative './linkedin_profile'
require_relative './instagram_profile'
require_relative './xing_profile'
require_relative './researchgate_profile'
require_relative './upwork_profile'
require_relative './facebook_profile'
require_relative './stackoverflow_profile'

