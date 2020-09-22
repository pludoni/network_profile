require_relative './network_profile_without_extraction'

module NetworkProfile
  class InstagramProfile < NetworkProfileWithoutExtraction
    self.mdi_icon = 'instagram'
    def self.handle?(link)
      (e = link[%r{instagram.com/([\w\.]+)}, 1]) && e.length > 3 && e != 'groups'
    end

    def profile_description
      "Instagram Profil:"
    end
  end
end
