module NetworkProfile
  class ResearchgateProfile < DefaultProfile
    self.mdi_icon = ''

    def self.handle?(link)
      link['researchgate.net/profile/']
    end

    def json_ld
      original = super
      if original['@graph']
        original['@graph'].first
      else
        original
      end
    end

    def title
      json_ld['name']
    end

    def text
      json_ld.dig('affiliation', 'name') || doc.at('.org')&.text
    end

    def last_item
      item = rdf.find { |_, v| v['type'].to_s['ScholarlyArticle'] }.last
      return unless item

      title = item.dig('<http://schema.org/headline>', 0)
      date = item.dig('<http://schema.org/datePublished>', 0)
      "#{title} (#{date})"
    end

    def extra_data
      items, reads, citations = doc.at(".profile-content-item .nova-c-card").
        search(".nova-o-grid__column").
        map { |col| col.search('.nova-e-text').map(&:text) }.
        map(&:first).map { |i| i.gsub(',', '').to_i }

      { items: items, reads: reads, citations: citations, last_item: last_item }
    end
  end
end
