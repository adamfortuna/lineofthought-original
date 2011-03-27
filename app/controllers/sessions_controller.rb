class SessionsController < Devise::SessionsController
  ssl_required :new, :create
end