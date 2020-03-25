# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  before_action :set_raven_context
  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= SessionProvider.new(cookies).current_user
  rescue JWT::VerificationError => e
    # TODO: logout user with invalid session
    Raven.capture_exception(e)
    raise ActionController::Forbidden
  end

  def logged_in?
    current_user != nil
  end

  def authenticate_user!
    # TODO: redirect to login instead
    head :unauthorized unless logged_in?
  end

  private

  def set_raven_context
    Raven.user_context(
      id: current_user&.id,
      email: current_user&.email,
      external_id: current_user&.external_id
    )
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
