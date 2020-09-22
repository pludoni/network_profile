require 'active_support/core_ext/string/filters'

module NetworkProfile
  class UpworkProfile < DefaultProfile
    self.mdi_icon = 'upwork'
    def self.handle?(link)
      link[%r{upwork.com/o/profiles/users/.+}]
    end

    def title
      php_vars.dig('profile', 'profile', 'name')
    end

    def text
      doc.at('h2 strong').text
    end

    def php_vars
      @php_vars ||=
        begin
          t = doc.search('script').find { |i| i && i.text['PROFILE_RESPONSE'] }.text
          t.remove!(/window.PROFILE_RESPONSE=.*summary:/)
          JSON.parse(t.remove(/\}$/))
        end
    end

    def extra_data
      profile = php_vars.dig('profile')
      rate = profile.dig('stats', 'hourlyRate')
      {
        country: profile.dig('profile', 'location').yield_self { |v| "#{v['city']}, #{v['country']}" },
        hours: profile.dig('stats', 'totalHours').floor,
        jobs: profile.dig('stats', 'totalJobsWorked').floor,
        rating: profile.dig('stats', 'rating').round(2),
        hourly_rate: "#{rate['amount']} #{rate['currencyCode']}",
        english_level: profile['stats']['englishLevel'],
        hire_again: profile.dig('stats', 'hireAgainPercentage'),
        skills: profile.dig('profile', 'skills').map { |i| i['prettyName'] }
      }
    end
  end
end
