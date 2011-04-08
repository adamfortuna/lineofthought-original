require "spec_helper"

describe Site do
  context 'relationships' do
    it { should have_many(:usings) }
    it { should have_many(:tools) }
  end

  context 'validations' do
    it { should validate_presence_of(:url) }
  end
end