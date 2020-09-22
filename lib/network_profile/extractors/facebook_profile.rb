require_relative './network_profile_without_extraction'

module NetworkProfile
  class FacebookProfile < NetworkProfileWithoutExtraction
    self.mdi_icon = 'facebook'

    def self.handle?(link)
      (e = link[%r{facebook.com/([\w\.]+)}, 1]) && e.length > 3 && e != 'groups'
    end

    def profile_description
      "Facebook Profil:"
    end
  end
end
