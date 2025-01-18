class Todo < ApplicationRecord
  # Statuses list
  PENDING = 'pending'.freeze
  IN_PROGRESS = 'in_progress'.freeze
  DONE = 'done'.freeze

  STATUSES = {
    PENDING => PENDING,
    IN_PROGRESS => IN_PROGRESS,
    DONE => DONE
  }.freeze

  enum status: STATUSES

  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :title, :description, presence: true
  validates :title, uniqueness: true
end
