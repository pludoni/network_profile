module NetworkProfile
  # Tags:
  # https://api.stackexchange.com/2.2/users/220292/top-tags?pagesize=10&site=stackoverflow

  class StackoverflowProfile < DefaultProfile
    self.mdi_icon = 'stack-overflow'
    SITES = [
      ["https://stackoverflow.com", "stackoverflow", "Stack Overflow"],
      ["https://serverfault.com", "serverfault", "Server Fault"],
      ["https://superuser.com", "superuser", "Super User"],
      ["https://webapps.stackexchange.com", "webapps", "Web Applications"],
      ["https://gaming.stackexchange.com", "gaming", "Arqade"],
      ["https://webmasters.stackexchange.com", "webmasters", "Webmasters"],
      ["https://cooking.stackexchange.com", "cooking", "Seasoned Advice"],
      ["https://gamedev.stackexchange.com", "gamedev", "Game Development"],
      ["https://photo.stackexchange.com", "photo", "Photography"],
      ["https://stats.stackexchange.com", "stats", "Cross Validated"],
      ["https://math.stackexchange.com", "math", "Mathematics"],
      ["https://diy.stackexchange.com", "diy", "Home Improvement"],
      ["https://gis.stackexchange.com", "gis", "Geographic Information Systems"],
      ["https://tex.stackexchange.com", "tex", "TeX - LaTeX"],
      ["https://askubuntu.com", "askubuntu", "Ask Ubuntu"],
    ].freeze

    def self.handle?(link)
      SITES.any? { |s, _, _| link.include?(s + "/users/") }
    end

    def site
      @site ||= SITES.find { |s, _, _| @link.include?(s) }
    end

    def title
      user_api['display_name']
    end

    def image
      user_api['profile_image']
    end

    def text
    end

    def extra_data
      {
        reputation: user_api.dig('reputation'),
        created: Time.at(user_api['creation_date']).to_date,
        location: user_api.dig('location'),
        site: site[2],
        site_logo: "https://cdn.sstatic.net/Sites/#{site[1]}/img/apple-touch-icon.png",
        tags: tags_api.map { |j| [j['tag_name'], j['answer_score'] + j['question_score']] }
      }
    end

    def user_id
      URI.parse(@link).path[%r{/users/(\d+)/?}, 1]
    end

    private

    def user_api
      @user_api ||=
        begin
          url = "https://api.stackexchange.com/2.2/users/#{user_id}?order=desc&sort=reputation&site=#{site[1]}"
          api_call(url).dig('items', 0)
        end
    end

    def tags_api
      @tags_api ||=
        begin
          url = "https://api.stackexchange.com/2.2/users/#{user_id}/top-tags?pagesize=10&site=#{site[1]}"
          api_call(url).dig('items')
        end
    end

    def api_call(url)
      JSON.parse(Typhoeus.get(url, accept_encoding: 'gzip').body)
    end
  end
end
