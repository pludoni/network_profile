RSpec.describe "Github with missing data" do
  include WebMock::API

  around do |example|
    old_key = NetworkProfile.github_api_key
    NetworkProfile.github_api_key = 'test'
    WebMock.enable!
    example.run
  ensure
    WebMock.reset!
    WebMock.disable!
    NetworkProfile.github_api_key = old_key
  end

  def stub_graphql(data)
    stub_request(:post, "https://api.github.com/graphql").
      to_return(status: 200, body: { data: data }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe NetworkProfile::GithubProject do
    it "returns nil for a repository the API does not know" do
      stub_graphql(repository: nil)
      # two URLs pasted into one field
      link = "https://github.com/SaugatSaurav/      ,   https://www.linkedin.com/in/saugat-subedi-609293438/"

      expect(NetworkProfile.parse(link, include_fallback_custom: true)).to be_nil
    end

    it "handles an empty repository without commits" do
      stub_graphql(repository: {
                     nameWithOwner: "foo/bar",
                     createdAt: "2020-01-02T03:04:05Z",
                     defaultBranchRef: nil
                   })

      result = NetworkProfile.parse("https://github.com/foo/bar")
      expect(result[:title]).to be == "foo/bar"
      expect(result[:created]).to be == Date.new(2020, 1, 2)
      expect(result[:last_commit]).to be_nil
    end
  end

  describe NetworkProfile::GithubProfile do
    it "returns nil for a user the API does not know" do
      stub_graphql(organization: nil, user: nil)

      expect(NetworkProfile.parse("https://github.com/does-not-exist-123")).to be_nil
    end

    it "handles pinned items without dates" do
      stub_graphql(organization: nil, user: {
                     name: "Foo",
                     pinnedItems: { edges: [{ node: { nameWithOwner: "foo/bar", stargazers: { totalCount: 1 }, watchers: { totalCount: 2 } } }] }
                   })

      result = NetworkProfile.parse("https://github.com/foo")
      expect(result[:title]).to be == "Foo"
      expect(result[:pinned].first).to include(name: "foo/bar", created: nil, updated: nil)
    end
  end
end
