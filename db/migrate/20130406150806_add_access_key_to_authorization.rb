class AddAccessKeyToAuthorization < ActiveRecord::Migration
  def change
    add_column :authorizations, :access_key_1 ,:string
    add_column :authorizations, :access_key_2 ,:string
  end
end
