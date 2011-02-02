require 'spec_helper'

describe Tool do
  context 'relationships' do
    it { should belong_to(:language) }
    it { should have_many(:buildables) }
    it { should have_many(:categories) }
    it { should have_many(:usings) }
    it { should have_many(:sites) }
    it { should have_many(:sources) }
  end

  context 'validations' do
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:url) }
    
    it { should_not allow_value("test").for(:url) }      
  end
end