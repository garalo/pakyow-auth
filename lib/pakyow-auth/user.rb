module Pakyow
  module Auth
    class User
      include DataMapper::Resource

      attr_accessor :password, :password_confirmation

      property :id,                   Serial
      property :email,                String 
      property :crypted_password,     String
      property :salt,                 String

      validates_confirmation_of :password
      validates_presence_of     :crypted_password, :message => 'Password must not be blank'

      before :save, :encrypt_password

      # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
      def self.authenticate(email, password)
        u = User.first(:email => email) # need to get the salt
        if u && u.authenticated?(password)
          return u
        else
          return [ false, "Invalid email address or password" ]
        end
      end

      def authenticated?(password)
        true if self.crypted_password == encrypt(password)
      end
  
      private
  
      def encrypt_password
        return if self.password.blank?
        self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if self.created_at == self.updated_at
        self.crypted_password = encrypt(password)
      end

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
