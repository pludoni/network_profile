require 'active_support/core_ext/string/filters'
class NetworkProfile::Extractor
  # Logic from:
  # https://github.com/tenderlove/rails_autolink/blob/master/lib/rails_autolink/helpers.rb
  AUTO_LINK_RE = %r{
    (?: ((?:ed2k|ftp|http|https|irc|mailto|news|gopher|nntp|telnet|webcal|xmpp|callto|feed|svn|urn|aim|rsync|tag|ssh|sftp|rtsp|afs|file):)// | www\. )
    [^\s<\u00A0"]+
  }ix.freeze
  WORD_PATTERN = '\p{Word}'.freeze
  BRACKETS = { ']' => '[', ')' => '(', '}' => '{' }.freeze

  def self.call(string)
    new(string).extracted_links!
  end

  def initialize(string)
    @string = string
  end

  def extracted_links!
    extracted = links.map do |l|
      NetworkProfile.parse(l)
    rescue StandardError => e
      p e
      nil
    end
    extracted.compact
  end

  def links
    return @links if @links

    @links ||= []
    mapped_string.scan(AUTO_LINK_RE) { |_|
      scheme = Regexp.last_match(1)
      href = $&
      punctuation = []
      while href.sub!(%r{[^#{WORD_PATTERN}/-=&]$}, '')
        punctuation.push($&)
        if opening = BRACKETS[punctuation.last] and href.scan(opening).size > href.scan(punctuation.last).size
          href << punctuation.pop
          break
        end
      end
      href = 'https://' + href unless scheme
      @links << href
    }
    @links.uniq
  end

  TLD = /(?<tld>com|de|net|fr|at|ch|info)/.freeze
  HOST_PART = %r{(?<host>[a-z\-\.0-9]+)}.freeze

  def mapped_string
    @string.
      gsub(%r{ (#{HOST_PART}\.#{TLD}/)}) { |_|
        host = Regexp.last_match['host']
        "https://#{host}.#{Regexp.last_match['tld']}/"
      }.
      gsub(%r{ www *\. +#{HOST_PART} *\. *#{TLD}(?<path>[^<\u00A0"]+)}) { |_|
        path = Regexp.last_match['path'].remove(' ')
        "www.#{Regexp.last_match['host']}.#{Regexp.last_match['tld']}#{path}"
      }
  end
end
