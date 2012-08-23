module Pakyow
  module Auth
    module UserMethods
      module ClassMethods
        @@login_field = :email
        
        def login_field
          @@login_field
        end

        # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
        def authenticate(session)
          u = self.first(self.login_field => session.login) # need to get the salt
          if u && u.authenticated?(session.password)
            return u
          else
            return false 
          end
        end

        # Encrypts some data with the salt.
        def encrypt(password, salt)
          Digest::SHA1.hexdigest("--#{salt}--#{password}--")
        end
      end

      attr_accessor :password, :password_confirmation

      def self.included(o)
        o.storage_names[:default] = "users"

        o.property :id,                   DataMapper::Property::Serial
        o.property :crypted_password,     String
        o.property :salt,                 String
        o.property :password_reset_token, String, :required => false, :length => 128
        o.property :password_reset_token_expiration, DateTime, :required => false

        o.extend Pakyow::Auth::UserMethods::ClassMethods
      end

      def create_password_reset_token
        self.password_reset_token = rand(36**64).to_s(36)
        self.password_reset_token_expiration = Date.today + 5
      end

      def password=(p)
        return if p.nil? || p.empty?
        @password = p
        
        self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{User.login_field}--") 
        self.crypted_password = self.class.encrypt(p, salt)
      end

      def authenticated?(password)
        true if self.crypted_password == self.class.encrypt(password, salt)
      end
    end
  end
end
