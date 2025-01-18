# Format model errors for frontend error messages
# @param [Object] model
module FormatModelErrorsService
  def self.call(model)
    model.errors.messages.transform_values { |msgs| msgs[0] }
  end
end
