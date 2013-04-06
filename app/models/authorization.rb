class Authorization < ActiveRecord::Base
  attr_accessible :provider, :uid, :user, :access_key_1, :access_key_2
  belongs_to :user
  validates :provider, :uid, :presence => true
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_or_create(auth_hash)
    unless auth = find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      user = User.create :name => auth_hash["info"]["name"], 
                         :email => (auth_hash["info"]["email"] or "noemail"), 
                         :image => auth_hash["info"]["image"]
      auth = create :user => user, :provider => auth_hash["provider"], :uid => auth_hash["uid"]
      auth.update_access_keys(auth_hash)
    end
    return auth
  end

  def update_access_keys(auth_hash)
    case self.provider
      when "facebook" 
        update_attributes :access_key_1 => auth_hash["credentials"]["token"]
      when "twitter"
        update_attributes :access_key_1 => auth_hash["credentials"]["token"], :access_key_2 => auth_hash["credentials"]["secret"]
      when "linkedin"
        update_attributes :access_key_1 => auth_hash["credentials"]["token"], :access_key_2 => auth_hash["credentials"]["secret"]
    end
      
  end


  def self.providers
    ["facebook", "twitter", "linkedin", "google"]
  end
  
  def self.colors
    ["primary", "info", "success", "warning"]
  end

end
