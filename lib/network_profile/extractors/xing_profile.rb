module NetworkProfile
  class XingProfile < DefaultProfile
    self.mdi_icon = 'xing'

    def self.handle?(link)
      link['xing.com/profile/']
    end

    def title
      doc.at('h1').text.strip
    end

    def text
      json_ld.dig('jobTitle')
    end

    def extra_data
      {
        employment_status: doc.at('[data-qa=xing-id-work_experience]')&.text&.split(', ')&.first,
        tags: json_ld&.fetch('makesOffer', [])&.map { |i| i['name'] } || [],
        languages: doc.at('[data-qa=language-skills-section]')&.search('li')&.map { |i| "#{i.at('h3').text} (#{i.at('div').text})" },
      }
    end
  end
end
