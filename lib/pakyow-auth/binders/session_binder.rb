module Pakyow
  module Auth
    class SessionBinder < Pakyow::Presenter::Binder
      binder_for :session

      def action
        { :action => '/sessions', :method => 'post' }
      end
    end
  end
end

