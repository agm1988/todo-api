# Not really relevant, just an example for errors and responses could be handled
module ApiConcern
  extend ActiveSupport::Concern

  included do
    # respond_to :json
    rescue_from StandardError, with: :render_server_error unless Rails.env.development?
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
    rescue_from ActiveRecord::RecordNotUnique, with: :render_not_unique
    rescue_from JSON::ParserError, with: :render_json_parse_error
    rescue_from Errors::ServiceArgumentsError, with: :render_service_argument_error
    rescue_from ArgumentError, with: :render_argument_error
  end

  private

  def render_not_unique(error)
    render_error(error: error.message, status: 422)
  end

  def render_argument_error(error)
    render_error(error: error.message, status: 422)
  end

  def render_service_argument_error(_error)
    render_error(error: I18n.t('errors.service_arguments_error'), status: 400)
  end

  def render_json_parse_error(error)
    render_error(error: error.message, status: 400)
  end

  def render_record_invalid(error)
    render_json_error(error: format_model_errors(error.record))
  end

  def render_permissions_missing(_error)
    render_json_error(error: I18n.t('errors.no_permissions'), status: 403)
  end

  def render_server_error(error)
    if Rails.env.production?
      Sentry.capture_exception(error)
      render_json_error(error: I18n.t('errors.something_went_wrong'), status: 500)
    else
      render_error error: error.inspect, status: 500
    end
  end

  def render_not_found(error)
    render_error error: I18n.t('errors.record_not_found'),
                 data: {
                   id: error&.id,
                   model: error&.model,
                   primary_key: error&.primary_key
                 },
                 status: 404
  end

  def render_parameter_missing(error)
    render_error data: error
  end

  # def render_error(error: I18n.t('errors.something_went_wrong'), data: nil, status: 400)
  #   render json: { error: error, data: data }, status: status
  # end

  def render_error(error: I18n.t('errors.something_went_wrong'), data: nil, status: 400)
    render json: { message: error, data: data }, status: status
  end

  def bad_request
    render json: { error: I18n.t('errors.bad_request') }, status: 400
  end

  def render_json_error(error:, status: 422)
    render json: {
      error: convert_from_json(error)
    }, status: status
  end

  def render_inactive(status: 200)
    render json: { inactive: true }, status: status
  end

  def render_success(status: 200)
    render json: { success: true }, status: status
  end

  def format_model_errors(model)
    FormatModelErrorsService.call(model)
  end

  # TODO: move to helper
  def convert_from_json(str)
    return str unless str.is_a?(String)

    JSON.parse(str)
  rescue JSON::ParserError => _e
    str
  end

  def set_language
    locale_header = request.headers['User-Locale']&.scan(/^[a-z]{2}/)&.first&.to_sym
    locale_params = params[:locale]

    I18n.locale = locale_params if locale_params.present?
    I18n.locale = locale_header if locale_header.present?
  end
end
