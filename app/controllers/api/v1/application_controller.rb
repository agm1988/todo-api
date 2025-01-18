class Api::V1::ApplicationController < ApplicationController
  include ActionController::MimeResponds
  include ApiConcern
end
