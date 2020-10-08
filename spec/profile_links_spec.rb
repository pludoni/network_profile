RSpec.describe "Profile Links" do
  describe "Github", github: true do
    before(:each) do
      if ENV['GITHUB_API_KEY']
        NetworkProfile.github_api_key = ENV['GITHUB_API_KEY']
      end
      if ENV['GH_API_KEY']
        NetworkProfile.github_api_key = ENV['GH_API_KEY']
      end
      if NetworkProfile.github_api_key == nil
        skip "Skipping Github specs because no NetworkProfile.github_api_key is set"
      end
    end

    specify 'Profil' do
      link = "https://github.com/zealot128/"
      extraction = NetworkProfile.parse(link)
      expect(extraction[:title]).to be == 'Stefan Wienert'
      expect(extraction[:company]).to be == 'pludoni GmbH'
    end

    specify 'Organization' do
      link = "https://github.com/discourse"
      extraction = NetworkProfile.parse(link)
      expect(extraction[:title]).to be == 'Discourse'
    end

    specify 'Project' do
      link = "https://github.com/zealot128/filter-app"
      extraction = NetworkProfile.parse(link)
      expect(extraction[:title]).to be == 'zealot128/filter-app'
      expect(extraction[:text]).to be == 'Rails app - news aggregator that powers http://hrfilter.de and http://fahrrad-filter.de'
      expect(extraction[:commits]).to be > 860
      expect(extraction[:stars]).to be > 10
      expect(extraction[:forks]).to be > 5
      expect(extraction[:watchers]).to be > 5
      expect(extraction[:last_commit]).to be > Date.new(2020, 1, 1)
    end
  end

  describe "Xing" do
    specify 'Joerg' do
      link = "https://www.xing.com/profile/Joerg_Klukas"
      extraction = NetworkProfile.parse(link)
      expect(extraction[:title]).to be == 'Prof. Dr. Jörg Klukas'
      expect(extraction[:text]).to be == 'Professor für Personalmanagement, Führung und Nachhaltigkeit'
      expect(extraction[:image]).to include 'klukas.1024x1024.jpg'
    end
  end

  specify 'Research Gate' do
    link = "https://www.researchgate.net/profile/Sandra_Ciesek"
    extraction = NetworkProfile.parse(link)
    expect(extraction[:title]).to be == 'Sandra Ciesek'
    expect(extraction[:text]).to be == 'University Hospital Frankfurt'
    expect(extraction[:image]).to include ".jpg"
    expect(extraction[:items]).to be >= 50
    expect(extraction[:reads]).to be >= 2000
    expect(extraction[:citations]).to be >= 1000
    expect(extraction[:last_item]).to_not be == nil
  end

  specify 'Research Gate' do
    link = "https://www.researchgate.net/profile/Sandra_Ciesek"
    extraction = NetworkProfile.parse(link)
    expect(extraction[:title]).to be == 'Sandra Ciesek'
    expect(extraction[:text]).to be == 'University Hospital Frankfurt'
    expect(extraction[:image]).to include ".jpg"
    expect(extraction[:items]).to be >= 50
    expect(extraction[:reads]).to be >= 2000
    expect(extraction[:citations]).to be >= 1000
    expect(extraction[:last_item]).to_not be == nil
  end

  specify 'Research - Captcha does not crash' do
    expect_any_instance_of(NetworkProfile::DefaultProfile).to receive(:response).and_return(OpenStruct.new(
      body: "<html><body>CAPTCHA</body></html>"
    ))
    link = "https://www.researchgate.net/profile/Sandra_Ciesek"
    extraction = NetworkProfile.parse(link)
    p extraction
  end

  describe "No extraction - only matching" do
    specify "Facebook (no extraction)" do
      extraction = NetworkProfile.parse("https://www.facebook.com/gdoerner")
      expect(extraction[:type]).to be == 'facebook_profile'
    end
    specify 'Joerg' do
      link = "https://www.linkedin.com/in/jklukas/"
      extraction = NetworkProfile.parse(link)
      expect(extraction[:type]).to be == 'linkedin_profile'
    end

    specify "Instagram" do
      link = "https://www.instagram.com/vincent_the/"
      extraction = NetworkProfile.parse(link)
      expect(extraction[:type]).to be == 'instagram_profile'
    end
  end

  specify "Upwork" do
    link = "https://www.upwork.com/o/profiles/users/~01b16036da7663b295/"
    extraction = NetworkProfile.parse(link)
    expect(extraction[:title]).to be == "Islam M."
    expect(extraction[:text]).to include 'PHP Expert'
    expect(extraction[:image]).to include 'https://'
    expect(extraction[:hourly_rate]).to be == '35 USD'
    expect(extraction[:jobs]).to be >= 20
    expect(extraction[:hours]).to be >= 400
  end

  specify 'Stackoverflow' do
    link = "https://stackoverflow.com/users/220292/stwienert"
    extraction = NetworkProfile.parse(link)
    expect(extraction[:title]).to be == "stwienert"
    expect(extraction[:image]).to include "https"
    expect(extraction[:location]).to be == 'Dresden, Germany'
    expect(extraction[:reputation]).to be > 1000
    expect(extraction[:created]).to be_kind_of(Date)
  end

  specify 'Custom - Homepage' do
    link = "https://www.stefanwienert.de/"
    extraction = NetworkProfile.parse(link, include_fallback_custom: true)
    expect(extraction[:title]).to include "Stefan Wienert"
    # expect(extraction[:image]).to
    # expect(extraction[:text]).to be_present
  end

  # Behance Profile: https://www.behance.net/xoxotuane0c4
  # Behance Project: https://www.behance.net/gallery/77399191/Product-Design-Portfolio-2019?tracking_source=search-all%7Cdonlion%3Ftracking_source%3Dsearch-all%7Cdonlion
  # DOI: http://doi.org/10.5281/zenodo.1212234
  #      http://doi.org/10.1080/01626620.2014.977700
end
