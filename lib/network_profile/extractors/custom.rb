module NetworkProfile
  class Custom < DefaultProfile
    self.mdi_icon = 'open-in-new'

    def self.handle?(link)
      true
    end
  end
end
