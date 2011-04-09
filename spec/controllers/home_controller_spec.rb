require 'spec_helper'

describe HomeController do
 
  render_views

  describe "#index" do
    before :each do
      get :index
    end
 
    it { should route(:get, root_path).to(:action => :index) }
    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should_not set_the_flash }
  end
  

  describe "#welcome" do
    before :each do
      get :welcome
    end
 
    it { should route(:get, welcome_path).to(:action => :welcome) }
    it { should respond_with(:success) }
    it { should render_template(:welcome) }
    it { should_not set_the_flash }
  end

  
  describe "#stream" do
    before :each do
      get :stream
    end
 
    it { should route(:get, stream_path).to(:action => :stream) }
    it { should respond_with(:success) }
    it { should render_template(:stream) }
    it { should_not set_the_flash }
  end
 
  describe "#about" do
    before :each do
      get :about
    end
 
    it { should route(:get, about_path).to(:action => :about) }
    it { should respond_with(:success) }
    it { should render_template(:about) }
    it { should_not set_the_flash }
  end
end
