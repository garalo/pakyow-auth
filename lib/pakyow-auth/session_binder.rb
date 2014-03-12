module Pakyow
  module Auth
    class SessionBinder < Pakyow::Presenter::Binder
      binding :session

      def action
        { :action => '/sessions', :method => 'post' }
      end
    end
  end
end

