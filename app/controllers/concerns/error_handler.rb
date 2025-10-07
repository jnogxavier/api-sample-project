
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  end

  private

  def render_not_found(exception)
    render json: {
      error: "Record not found",
      message: exception.message
    }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    render json: {
      errors: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def render_validation_errors(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
