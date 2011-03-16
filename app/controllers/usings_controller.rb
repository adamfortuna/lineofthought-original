class UsingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_record, :only => [:update, :destroy]

  def update
    respond_to do |format|
      format.js {
        if @using.update_attributes(params[:using])
          render 'update.js'
        else
          render :js => "alert('problem');"
        end
      }
    end
  end
  
  # DELETE /using
  def destroy
    respond_to do |format|
      format.js {
        if @using.destroy
          render 'destroy.js'
        else
          render :js => "alert('problem');"
        end
      }
    end
  end

  private

  def load_record
    @using = Using.find(params[:id])
  end
end