require 'active_support/core_ext/string/inflections'
require_relative './default_profile.rb'

module NetworkProfile
  class NetworkProfileWithoutExtraction < DefaultProfile
    def profile_description
      "Profil: "
    end

    def title
      "#{profile_description} #{@link.split('/').last}"
    end

    def data
      {
        title: title,
        text: "",
        image: nil,
        type: self.class.name.underscore.split('/').last,
        link: @link,
        site_icon: self.class.mdi_icon,
      }
    end
  end
end
