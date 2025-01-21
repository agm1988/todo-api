class Api::V1::TodosController < Api::V1::ApplicationController
  before_action :set_todo, only: %i[show update destroy]

  def index
    filters = params[:filters] || {}

    todos = Todos::TodosSearchService.call(todo_id: params[:todo_id],
                                           meta: {
                                             offset: params[:offset],
                                             per_page: params[:per_page],
                                             order: params[:order],
                                             order_by: params[:order_by]
                                           },
                                           search: params[:search],
                                           filters: filters.to_unsafe_hash)

    render json: todos
  end

  def show
    render json: @todo
  end

  def create
    todo = Todo.new(todo_params)
    todo.save!

    render json: todo, status: :created
  end

  def update
    @todo.update!(todo_params)

    render json: @todo
  end

  def destroy
    @todo.destroy
    head :no_content
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :status)
  end
end
