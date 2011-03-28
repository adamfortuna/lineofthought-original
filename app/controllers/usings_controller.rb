class UsingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_record, :only => [:update, :destroy]
  cache_sweeper :using_sweeper, :only => [:update, :destroy]

  def update
    respond_to do |format|
      format.js {
        if current_user.can_edit_using?(@using) && @using.update_attributes(params[:using])
          render 'update.js'
        else
          render :js => "alert('Cannot edit.');"
        end
      }
    end
  end
  
  # DELETE /using
  def destroy
    respond_to do |format|
      format.js {
        if current_user.can_destroy_using?(@using) && @using.destroy
          render 'destroy.js'
        else
          render :js => "alert('Cannot delete.');"
        end
      }
    end
  end

  private

  def load_record
    @using = Using.find(params[:id])
  end
end