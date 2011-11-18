module Pakyow
  module Auth
    class User
      class << self
        @@login_field = :email
        
        @@secondary_field = nil
        
        def login_field
          @@login_field
        end
        
        def secondary_field
          @@secondary_field
        end
      end
      
      include DataMapper::Resource

      storage_names[:default] = "users"
      
      attr_accessor :password, :password_confirmation

      property :id,                   Serial      
      property :crypted_password,     String
      property :salt,                 String
      
      def password=(p)
        @password = p
        
        digest_field = self.send(self.class.login_field)
        if digest_field.nil? || digest_field.to_s.empty?
          if self.class.secondary_field && !self.send(self.class.secondary_field).nil?
            digest_field = self.send(self.class.secondary_field)
          end
        end
        
        self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{digest_field}--") 
        self.crypted_password = encrypt(p)
      end
      
      # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
      def self.authenticate(session)
        u = self.first(self.login_field => session.login) # need to get the salt
        if u && u.authenticated?(session.password)
          return u
        else
          if self.secondary_field && (u = self.first(self.secondary_field => session.login)) && u.authenticated?(session.password)
            return u
          else
            return false
          end
        end
      end

      def authenticated?(password)
        true if self.crypted_password == encrypt(password)
      end
  
      private
  
      # Encrypts the password with the user salt
      def encrypt(password)
        self.class.encrypt(password, salt)
      end

      # Encrypts some data with the salt.
      def self.encrypt(password, salt)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
      end
    end
  end
end

