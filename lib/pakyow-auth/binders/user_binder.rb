module Pakyow
  module Auth
    module UserBinder

      def password_reset_token
        {
          :value => bindable.password_reset_token
        }
      end

      def password_reset_url
        {
          :href => "#{$url}users/set_password/#{bindable.password_reset_token}",
          :content => "#{$url}users/set_password/#{bindable.password_reset_token}"
        }
      end

    end
  end
end


