module Pakyow
  module Auth
    class Session
      attr_accessor :login, :password

      def initialize(s = nil)
        return if s.nil? || s.empty?

        self.login    = s[:login]
        self.password = s[:password]
      end
    end
  end
end

