class User < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :oauth_token, :refresh_token, :sf_reference
  has_many :documents
end
