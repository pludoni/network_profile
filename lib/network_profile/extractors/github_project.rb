require_relative './github_graphql'

module NetworkProfile
  class GithubProject < DefaultProfile
    include GithubGraphql
    self.mdi_icon = 'github'

    def self.handle?(link)
      link.to_s[%r{github.com/[^/]+/.+}] && NetworkProfile.github_api_key
    end

    def query
      _, author, repo = @link.match(%r{github.com/([^/]+)/([^/\?]+)(\.git)?}).to_a
      <<~DOC
        query {
          repository(name:"#{repo}", owner: "#{author}") {
            createdAt
            description
            nameWithOwner
            updatedAt
            languages(first:10) {
              edges {
                node {
                  name
                }
                size
              }
              totalCount
            }
            licenseInfo { name }
            forkCount
            isFork
            defaultBranchRef {
              name
              target {
                ... on Commit {
                  committedDate
                  history(first: 0) {
                    totalCount
                  }
                }
              }
            }
            issues {
              totalCount
            }
            stargazers {
              totalCount
            }
            watchers {
              totalCount
            }
          }
        }
      DOC
    end

    def title
      json.dig('data', 'repository', 'nameWithOwner')
    end

    def text
      json.dig('data', 'repository', 'description')
    end

    def last_commit
      Time.parse(json.dig('data', 'repository', 'defaultBranchRef', 'target', 'committedDate')).to_date
    end

    def image
      nil
    end

    def extra_data
      {
        watchers: json.dig('data', 'repository', 'watchers', 'totalCount'),
        forks: json.dig('data', 'repository', 'forkCount'),
        stars: json.dig('data', 'repository', 'stargazers', 'totalCount'),
        issue_count: json.dig('data', 'repository', 'issues', 'totalCount'),
        commits: json.dig('data', 'repository', 'defaultBranchRef', 'target', 'history', 'totalCount'),
        license: json.dig('data', 'repository', 'licenseInfo', 'name'),
        created: Time.parse(json.dig('data', 'repository', 'createdAt')).to_date,
        language_bytes: json.dig('data', 'repository', 'languages', 'edges')&.map { |l| [l.dig('node', 'name'), l['size']] }&.sort_by { |_a, b| -b },
        last_commit: last_commit
      }
    end
  end
end
