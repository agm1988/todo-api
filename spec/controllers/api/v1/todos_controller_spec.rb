require 'rails_helper'

describe Api::V1::TodosController, type: :controller do
  let!(:pending_todo) { create(:todo)  }
  let!(:in_progress_todo) { create(:todo, :in_progress)  }
  let!(:done_todo) { create(:todo, :done)  }

  let(:todo_params) do
    { todo: {
      title: 'New Task',
      status: status }
    }
  end

  before(:each) do
    request.headers['accept'] = 'application/json'
  end

  describe '#index' do
    it "returns all todos" do
      get :index

      result = ActiveSupport::JSON.decode(response.body)

      expect(response).to have_http_status(:ok)
      expect(result['total_amount']).to eq(3)
      expect(result['data'].size).to eq(3)
    end
  end

  describe '#create' do
    let(:todo_params) do
      { todo: {
        title: title,
        description: 'New description',
        status: status }
      }
    end

    before(:each) do
      post :create, params: todo_params
    end

    # TODO: refactor to shared example 'it_behaves_like'
    context 'successful creation' do
      context 'pending' do
        let(:title) { Faker::Book.unique.title }
        let(:status) { Todo::PENDING }

        it "creates a new todo" do
          result = ActiveSupport::JSON.decode(response.body)

          expect(result['title']).to eq(title)
          expect(result['status']).to eq(Todo::PENDING)
          expect(response).to have_http_status(:created)
        end
      end

      context 'in_progress' do
        let(:title) { Faker::Book.unique.title }
        let(:status) { Todo::IN_PROGRESS }

        it "creates a new todo" do
          result = ActiveSupport::JSON.decode(response.body)

          expect(result['title']).to eq(title)
          expect(result['status']).to eq(Todo::IN_PROGRESS)
          expect(response).to have_http_status(:created)
        end
      end

      context 'done' do
        let(:title) { Faker::Book.unique.title }
        let(:status) { Todo::DONE }

        it "creates a new todo" do
          result = ActiveSupport::JSON.decode(response.body)

          expect(result['title']).to eq(title)
          expect(result['status']).to eq(Todo::DONE)
          expect(response).to have_http_status(:created)
        end
      end
    end

    context 'error on creation' do
      let(:status) { Todo::PENDING }

      context 'invalid without title' do
        let(:title) { nil }

        it 'returns an error on title' do
          result = ActiveSupport::JSON.decode(response.body)

          expect(result['error']['title']).to eq(I18n.t('activerecord.errors.models.todo.attributes.title.blank'))
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe '#update' do
    before(:each) do
      put :update, params: todo_params
    end

    context 'successful' do
      describe "updates title" do
        let(:todo_params) do
          {
            id: pending_todo.id,
            todo: {
              title: 'New title'
            }
          }
        end

        it "updates a todo" do
          expect(response).to have_http_status(:ok)
          expect(pending_todo.reload.title).to eq('New title')
        end
      end

      describe "updates status" do
        let(:todo_params) do
          {
            id: pending_todo.id,
            todo: {
              status: Todo::DONE
            }
          }
        end

        it "updates a todo" do
          expect(response).to have_http_status(:ok)
          expect(pending_todo.reload.status).to eq(Todo::DONE)
        end
      end
    end

    context 'error on update' do
      context 'invalid without title' do
        let(:todo_params) do
          {
            id: pending_todo.id,
            todo: {
              title: nil
            }
          }
        end

        it 'returns an error on title' do
          result = ActiveSupport::JSON.decode(response.body)

          expect(result['error']['title']).to eq(I18n.t('activerecord.errors.models.todo.attributes.title.blank'))
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe "#destroy" do
    it 'destroys todo' do
      expect {
        delete :destroy, params: { id: pending_todo.id }
      }.to change(Todo, :count).by(-1)
    end

    it 'not destroying todo' do
      expect {
        delete :destroy, params: { id: 'wrong' }
      }.not_to change(Todo, :count)
    end
  end
end
