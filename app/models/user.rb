class User < ActiveRecord::Base
  validates_presence_of :password, :on => :create
  has_secure_password
end
