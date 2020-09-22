require_relative './network_profile_without_extraction'

module NetworkProfile
  class LinkedinProfile < NetworkProfileWithoutExtraction
    self.mdi_icon = 'linkedin'
    def self.handle?(link)
      link['linkedin.com/in/']
    end

    def profile_description
      "LinkedIn Profil:"
    end
  end
end
