describe ToolsController do
 
  integrate_views
 
  describe "the index action" do
 
    before :each do
      stub(@article = Article.new).id { 1337 }
      mock(Tool).all { [@tool] }
      get :index
    end
 
    it { should route(:get, tools_path).to(:action => :index) }
    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should_not set_the_flash }
    it { should assign_to(:tools).with([@tool]) }
 
  end
end
