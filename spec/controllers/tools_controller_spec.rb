require 'spec_helper'

describe ToolsController do
 
  render_views
 
  describe "#index" do
    before :each do
      @tool = Factory.create(:tool, :featured => true)
      @category = Factory.create(:category)
    end
    subject { controller }

    context "with sql" do
      before { get :index }
 
      it { should route(:get, tools_path).to(:action => :index) }
      it { should respond_with(:success) }
      it { should render_template(:index) }
      it { should_not set_the_flash }
      it { should assign_to(:tools).with_kind_of(Array) }
      
      # it { should assign @tools => Tool.all }
      # it { should assigns[:tools].should == [@tool] }
      # it { should assigns[:tools].with([@tool]) }
        
        # should assign_to(:tools).with([@tool]) }
      # it { should assign_to(:categories).with([@category]) }
      # it { assign(:categories, [@category]) }
    end
  end
end
