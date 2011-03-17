class Admin::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_admin!
end
