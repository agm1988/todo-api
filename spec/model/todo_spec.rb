require 'rails_helper'

describe Todo, type: :model do
  describe 'validations' do
    let!(:todo) { FactoryBot.create(:todo) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }

    specify do
      expect(todo).to validate_uniqueness_of(:title)
    end
  end
end
