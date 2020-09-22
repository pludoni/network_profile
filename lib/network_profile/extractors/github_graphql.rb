require 'active_support/core_ext/hash/indifferent_access'

module NetworkProfile::GithubGraphql
  def query!(query)
    r = Typhoeus.post("https://api.github.com/graphql",
                      body: { query: query }.to_json,
                      headers: {
                        "Authorization": "bearer #{NetworkProfile.github_api_key}"
                      })
    if r.success?
      JSON.parse(r.body).with_indifferent_access
    else
      raise ArgumentError, "Fetching query failed: #{r.code}"
    end
  end

  def json
    @json ||= query!(query)
  end

  def doc
    raise NotImplementedError
  end
end
