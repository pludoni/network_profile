require_relative './github_graphql'

module NetworkProfile
  class GithubProfile < DefaultProfile
    include GithubGraphql
    self.mdi_icon = 'github'

    def self.handle?(link)
      link.to_s[%r{github.com/[^/]+/?$}] && NetworkProfile.github_api_key
    end

    def query
      username = @link[%r{github.com/([^/?#]+)}, 1]
      <<~DOC
        query {
          organization(login:"#{username}") {
            avatarUrl
            name
            bio: description
            location
            websiteUrl
            ...RepoFragment
          }

          user(login:"#{username}") {
            avatarUrl
            name
            bio
            company
            location
            websiteUrl
            followers {
              totalCount
            }
            ...RepoFragment
          }
        }
        fragment RepoFragment on ProfileOwner {
          pinnedItems(first: 9, types: [REPOSITORY]) {
            edges {
              node {
                ... on Repository {
                  nameWithOwner,
                  url,
                  createdAt,
                  updatedAt
                  stargazers { totalCount }
                  watchers {
                    totalCount
                  },
                  primaryLanguage {
                    name
                  }
                }
              }
            }
          }
        }
      DOC
    end

    def profile_data
      json.dig('data', 'organization') || json.dig('data', 'user')
    end

    def title
      profile_data['name']
    end

    def text
      profile_data['bio']
    end

    def image
      profile_data['avatarUrl']
    end

    def extra_data
      {
        company: profile_data['company'],
        location: profile_data['location'],
        profile_type: json.dig('data', 'organization') ? "organization" : "user",
        followers: profile_data.dig('followers', 'totalCount'),
        website: profile_data.dig('websiteUrl'),
        pinned: profile_data.dig('pinnedItems', 'edges').map { |i|
          n = i['node']
          { name: n['nameWithOwner'],
            url: n['url'],
            created: Time.parse(n['createdAt']).to_date,
            updated: Time.parse(n['updatedAt']).to_date,
            language: n.dig('primaryLanguage', 'name'),
            stars: n['stargazers']['totalCount'],
            watchers: n['watchers']['totalCount'] }
        }
      }
    end
  end
end
