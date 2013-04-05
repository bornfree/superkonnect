class Authorization < ActiveRecord::Base
  attr_accessible :provider, :uid, :user
  belongs_to :user
  validates :provider, :uid, :presence => true
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_or_create(auth_hash)
    unless auth = find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      user = User.create :name => auth_hash["info"]["name"], 
                         :email => (auth_hash["info"]["email"] or "noemail"), 
                         :image => auth_hash["info"]["image"]
      auth = create :user => user, :provider => auth_hash["provider"], :uid => auth_hash["uid"]
    end
    return auth
  end

  def self.providers
    ["facebook", "twitter", "linkedin", "google"]
  end
  
  def self.colors
    ["primary", "info", "success", "warning"]
  end

end
