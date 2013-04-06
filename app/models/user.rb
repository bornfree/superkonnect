class User < ActiveRecord::Base
  attr_accessible :email, :name, :image
  has_many :authorizations
  validates :name, :email, :presence => true

  def add_provider(auth_hash)
    unless auth_existing = authorizations.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      # No auth exists for this provider. Create one and update keys.
      auth = Authorization.create :user => self, :provider => auth_hash["provider"], :uid => auth_hash["uid"]
      auth.update_access_keys(auth_hash)
    else
      # Auth already exists but we need to update the access_tokens
      auth_existing.update_access_keys(auth_hash)
    end
  end

  def connected_with?(provider)
    authorizations.find_by_provider(provider)
  end

  def fetch_people(provider)
    # Using the param passed, find the authorization associated with it
    # and get people with the access keys in them
    list = nil
    case provider
      when "facebook" 
        auth = connected_with? provider
        list = facebook_friends(auth.access_key_1)
      when "twitter" 
        auth = connected_with? provider
        list = twitter_followers(auth.access_key_1, auth.access_key_2)
      when "linkedin" 
        auth = connected_with? provider
        list = linkedin_connections(auth.access_key_1, auth.access_key_2)
    end

    # If lookup fails (because access keys got invalidated) let the user re-authenticate by redirecting.
    # UI shouldn't allow any other scenario i.e fetch_people should'nt be hit if user never had this authorization.
    # If everything went well, return the list
    redirect_to "/auth/#{provider}" unless list
    return list
  end

  def facebook_friends(key)
    begin
      user = FbGraph::User.me(key)
      user = user.fetch
    rescue Exception
      return nil
    end
    return user.friends
  end

  def twitter_followers(key1, key2)
    begin
      user = Twitter::Client.new(:oauth_token => key1,
                               :oauth_token_secret => key2)
    rescue Exception
      return nil
    end
    list = []
    user.followers.each do |follower|
      list << follower
    end
    return list
  end

  def linkedin_connections(key1, key2)
    begin
      client = LinkedIn::Client.new('1ihgp8p3i0el', '0dMY7GrhM2CNeiPS')
      client.authorize_from_access(key1, key2)
    rescue Exception
      return nil
    end
    return client.connections["all"].collect {|connection| {"name" => "#{connection['first_name']} #{connection['last_name']}"} }
  end

end

# This is to make hashes behave like objects so that we can use object.method notation on hashes
# Primariy needed as linkedin API throws back an xml of connections and not objects that can be used like person.name
class Hash
  def method_missing(method_name, *args, &block)
    fetch(method_name.to_s)
  end
end
