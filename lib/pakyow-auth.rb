libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'pakyow-auth/user'

module Pakyow
  module Auth
    module Routes
      def self.included(base)
        base.class_eval {
          routes do
            get '/login' do 
              Auth.new_session 
            end
            
            get '/sessions/new' do  
              Auth.new_session
            end
            
            post '/sessions' do
              Auth.create_session
            end
            
            get '/logout' do
              Auth.delete_session
            end

            get '/users' do
              Auth.new_user
            end
            
            post '/users' do
              Auth.create_user
            end
          end
        }
      end
    end

    ###############
    # Sessions
    ###############
    
    def self.new_session
      Pakyow.app.instance_eval {
        presenter.use_view_path("sessions/new")
      }
    end

    def self.create_session
      Pakyow.app.instance_eval {
        if u = User.authenticate(request.params[:email], request.params[:password])
          request.session[:user] = u.id
          app.redirect_to '/'
        else
          Auth.new_session.call
        end
      }
    end

    def self.delete_session
      Pakyow.app.instance_eval {
        request.session[:user] = nil
      }
    end


    ###############
    # Users
    ###############
    
    def self.new_user
      Pakyow.app.instance_eval {
        presenter.use_view_path("users/new")
        presenter.view.bind(User.new)
      }
    end

    def self.create_user
      Pakyow.app.instance_eval {
        user = User.new(request.params[:user])
        # user.encrypt_password
    
        if user.valid?      
          user.save!
      
          redirect_to '/'
        else
          presenter.use_view_path("users/new")
          layout.bind(user)
        end
      }
    end
  end
end

