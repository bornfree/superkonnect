class User < ActiveRecord::Base
  attr_accessible :email, :name, :image
  has_many :authorizations
  validates :name, :email, :presence => true

  def add_provider(auth_hash)
    unless authorizations.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      Authorization.create :user => self, :provider => auth_hash["provider"], :uid => auth_hash["uid"]
    end
  end

  def connected_with?(provider)
    authorizations.find_by_provider(provider)
  end


end
