class UsingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_record, :only => [:update, :destroy]
  before_filter :verify_can_edit!, :only => :update
  before_filter :verify_can_delete!, :only => :destroy
  # cache_sweeper :using_sweeper, :only => [:update, :destroy]

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
  
  def verify_can_edit!
    if !current_user.can_edit_using?(@using)
      respond_to do |format|
        format.js { render :js => "alert('You do not have access to edit this line of thought.');" }
      end
    end
  end

  def verify_can_delete!
    if !current_user.can_destroy_using?(@using)
      respond_to do |format|
        format.js { render :js => "alert('You do not have access to delete this line of thought.');" }
      end
    end
  end
end