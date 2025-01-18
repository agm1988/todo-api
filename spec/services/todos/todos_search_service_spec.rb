require 'rails_helper'

describe Todos::TodosSearchService do
  let!(:pending_todo) { create(:todo, title: 'But some title for task')  }
  let!(:in_progress_todo) { create(:todo, :in_progress, title: 'A title for todo')  }
  let!(:done_todo) { create(:todo, :done, title: 'Some text here')  }

  context 'call' do
    it 'return all todos default sort' do
      expect(Todos::TodosSearchService.call[:data]).to eq([done_todo, in_progress_todo, pending_todo])
    end

    it 'should return by sorting newest to oldest' do
      expect(Todos::TodosSearchService.call(meta: { order: 'desc', order_by: 'created_at' })[:data]).to eq([done_todo, in_progress_todo, pending_todo])
    end

    it 'should return only done todos' do
      expect(Todos::TodosSearchService.call(filters: { 'status' => Todo::DONE })[:data]).to eq([done_todo])
    end

    it 'returns todos by title' do
      expect(Todos::TodosSearchService.call(search: pending_todo.title)[:data]).to eq([pending_todo])
    end

    it 'returns course by title order asc' do
      expect(Todos::TodosSearchService.call(meta: { order: 'asc', order_by: 'title' })[:data]).to eq([in_progress_todo, pending_todo, done_todo])
    end
  end
end
