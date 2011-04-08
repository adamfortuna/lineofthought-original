require 'spec_helper'

describe ToolsController do
 
  integrate_views
 
  describe "#index" do
    context "main action" do
      before :each do
        @tool = Factory.create(:tool)
        get :index
      end
 
      it { should route(:get, tools_path).to(:action => :index) }
      it { should respond_with(:success) }
      it { should render_template(:index) }
      it { should_not set_the_flash }
      it { should assign_to(:tools).with([@tool]) }
    end
  end
end
