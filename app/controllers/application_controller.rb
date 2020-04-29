class ApplicationController < ActionController::Base
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  def current_user
    "user2" # TODO 本来はここがログインユーザーのモデルを返却する
  end

  def forbidden
    render template: 'errors/error_403', status: 403, layout: 'application'
  end
end
