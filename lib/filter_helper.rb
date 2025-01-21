# frozen_string_literal: true

module FilterHelper
  # Helper for data filtering
  #
  # P.S. Need to add all joins (see table key) for tables when you initialize model for filtering data
  #
  # Example:
  #     FILTER_WITH_TABLES = {
  #       'status' => {
  #         table: :course_translations,
  #         field: :status,
  #         query: nil
  #       }
  #     }.freeze
  #
  # @param [Object] model - AR model instance
  # @param [Hash] filters - filters data
  # @param [Hash] rules - hash with rules for filtering
  def self.filter_helper(model:, filters:, rules:)
    return model unless filters.present?

    filters.each do |key, value|
      table_data = rules[key]

      # If we got incorrect key from the frontend
      next if table_data.blank?
      next unless value.present?

      table = table_data[:table]
      field = table_data[:field]
      query = table_data[:query]
      convertor = table_data[:convertor]

      value = convertor.call(value) if convertor

      # If manual query exists
      model = if query
                model.where(query, value: value)
              else
                model.where(table => { field => value })
              end
    end

    model
  end

  # @param [Object] model - AR model instance
  # @param [Hash] filters - filters data
  # @param [Hash] rules - hash with rules for filtering
  def self.aggregate_filter_helper(model:, filters:, rules:)
    return model unless filters.present?

    filters.each do |key, value|
      table_data = rules[key]

      # If we got incorrect key from the frontend
      next if table_data.blank?

      query = table_data[:query]
      convertor = table_data[:convertor]

      value = convertor.call(value) if convertor

      # If manual query exists
      model = model.having(query, value: value)
    end

    model
  end
end
