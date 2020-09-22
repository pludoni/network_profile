# NetworkProfile

Extractor Gem to analyse random strings for profile links of user. E.g. User uploads a PDF, scan it for all references to a social network profile.

This work is extracted from the German Applicant Tracking System EBMS (https://bms.empfehlungsbund.de).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'network_profile'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install network_profile

## Usage

### Parse and extract one link


    extraction = NetworkProfile.parse('https://github.com/zealot128', include_fallback_custom: true)

- ``include_fallback_custom: true`` uses the default extractor (og/meta-tags) if no other more specific extractor is found
- ``include_fallback_custom: false`` only use the specific website extractors and return nil if none matches the link

### Scan a whole long string for links

    links = NetworkProfile::Extractor.call("Very long String with even broken links in it www . github . com/zealot128")

### Config

    NetworkProfile.headers = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language' => 'de,en-US;q=0.7,en;q=0.3',
      'Referer' => 'https://www.google.com',
      'DNT' => '1',
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:73.0) Gecko/20100101 Firefox/73.0',
    }
    NetworkProfile.github_api_key = nil


## Extractor

The following network profiles are supported:

**GithubProfile/Company, GithubProject**:

  - uses GH's GraphQL API (Thus a API KEY is required)

**Instagram** **Facebook** **Linkedin**

  - Because those websites are closed and defensive as hell, there is no extraction, just a simple matching (e.g. "Facebook profile")

**Stackoverflow**

  - Uses SO's API

**Upwork** **XING**  **ResearchGate**

- Custom Website Scraper/Extract JSON+LD

**Default Fallback** (Custom)

- OG-Meta-Tags / HTML-Meta-Tags

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
