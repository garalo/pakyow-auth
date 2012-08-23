libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'pakyow-auth/binders/session_binder'
require 'pakyow-auth/binders/user_binder'
require 'pakyow-auth/orm/datamapper/user'
require 'pakyow-auth/orm/datamapper/session'

module Pakyow
  module Auth

    def self.routes
      Pakyow.app.instance_eval {
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
        
        get '/users/new' do
          Auth.new_user
        end
            
        post '/users' do
          Auth.create_user
        end
      }
    end

    ###############
    # Sessions
    ###############
    
    def self.new_session
      Pakyow.app.instance_eval {
        presenter.use_view_path("sessions/new")
        presenter.view.bind(Session.new)
      }
    end

    def self.create_session
      Pakyow.app.instance_eval {
        session = Session.new(request.params[:session])
        
        if u = ::User.authenticate(session)
          request.session[:user] = u.id
          app.redirect_to! '/'
        else
          #TODO: use invoke_route
          presenter.use_view_path("sessions/new")
          presenter.view.bind(session)
          
          # app.invoke_route!('/sessions/new', :get)
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
        presenter.view.bind(::User.new)
      }
    end

    def self.create_user
      Pakyow.app.instance_eval {
        user = ::User.new(request.params[:user])
        # user.encrypt_password
        
        if user.valid?      
          user.save!
      
          app.redirect_to! '/'
        else
          presenter.use_view_path("users/new")
          presenter.view.bind(user)
        end
      }
    end
  end
end

