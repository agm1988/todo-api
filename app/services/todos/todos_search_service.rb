# Todos search service
module Todos
  module TodosSearchService
    PER_PAGE = 10
    OFFSET = 0

    # Filter dictionary
    FILTER_WITH_TABLES = {
      'status' => {
        table: :todos,
        field: :status,
        query: nil,
        convertor: nil
      }
    }.freeze

    # Sort dictionary for frontend
    SORT_DICTIONARY = {
      'created_at' => 'todos.created_at', # todos created_at
      'title' => 'todos.title' # todos title
    }.freeze

    ASCENDING_ORDER = 'asc'.freeze
    DESCENDING_ORDER = 'desc'.freeze
    ORDER_DIRECTIONS = [ASCENDING_ORDER, DESCENDING_ORDER].freeze

    def self.call(todo_id: nil, meta: {}, search: nil, filters: {})
      model = main_query
      model = optional_where(model: model, todo_id: todo_id)
      # Filter data
      model = FilterHelper.filter_helper(model: model,
                                         filters: filters,
                                         rules: FILTER_WITH_TABLES)

      model = process_search_term(model: model, search: search) if search.present?
      order_sql = order_sql_query(meta)

      result(model: model, order_sql: order_sql, meta: meta)
    rescue NoMethodError, ActiveRecord::StatementInvalid => e
      raise Errors::ServiceArgumentsError, e.message
    end

    def self.result(model:, order_sql:, meta:)
      {
        total_amount: model.size,
        data: model.order(order_sql)
                   .offset(meta[:offset].present? ? meta[:offset] : OFFSET)
                   .limit(meta[:per_page].present? ? meta[:per_page] : PER_PAGE)
      }
    end

    # Needed if perform search on joined models
    def self.optional_where(model:, todo_id:)
      model = model.where('todos.id = :todo_id', todo_id: todo_id) if todo_id.present?
      model
    end

    def self.order_sql_query(meta)
      order_by = SORT_DICTIONARY[meta[:order_by]] || SORT_DICTIONARY['created_at']
      order_direction = ORDER_DIRECTIONS.include?(meta[:order].to_s.downcase) ? meta[:order] : DESCENDING_ORDER

      "#{order_by} #{order_direction} NULLS LAST"
    end

    def self.main_query
      Todo
        .distinct
        .select('todos.*')
        .all
    end

    def self.process_search_term(model:, search:)
      search = search.strip.downcase

      return multi_word_search(model: model, search: search) if search.split.size > 1

      single_word_search(model: model, search: search)
    end

    def self.single_word_search(model:, search:)
      model.where('todos.title ilike :search OR todos.description ilike :search',
                  search: "%#{search}%")
    end

    def self.multi_word_search(model:, search:)
      word1 = search.split[0]
      word2 = search.split[1..].join(' ')

      model.where("substring(LOWER(todos.title)::varchar from '^' || :search::varchar || '(.*)$') IS NOT NULL OR
                   todos.title ilike :word1 OR
                   todos.title ilike :word2 OR
                   todos.description ilike :word1 OR
                   todos.description ilike :word2",
                  search: search, #QueryNormalizer.remove_special_symbols(search)
                  word1: "%#{word1}%",
                  word2: "%#{word2}%")
    end
  end
end
