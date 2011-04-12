require 'spec_helper'

describe ToolsController do
 
  render_views
 
  describe "#index" do
    subject { controller }
    before :each do
      @tool = Factory.create(:tool, :featured => true)
      @category = Factory.create(:category)
      get :index
    end
 
    it { should route(:get, tools_path).to(:action => :index) }
    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should_not set_the_flash }
    it { should assigns[:tools] }
    # it { should assign_to(:tools).with([@tool]) }
    it { should assign_to(:categories).with([@category]) }
      
      # it { should assign @tools => Tool.all }
      # it { should assigns[:tools].should == [@tool] }
      # it { should assigns[:tools].with([@tool]) }
        
        # should assign_to(:tools).with([@tool]) }
      # it { should assign_to(:categories).with([@category]) }
      # it { assign(:categories, [@category]) }
  end
end
