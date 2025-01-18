class CreateTodos < ActiveRecord::Migration[7.2]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :status, null: false, default: ::Todo::PENDING

      t.timestamps
    end

    add_index :todos, :title, unique: true
    add_index :todos, :status
  end
end
