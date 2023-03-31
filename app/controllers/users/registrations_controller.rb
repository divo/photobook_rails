# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  before_action :set_orders, only: [:show, :edit]
  after_action :send_signup_mail, only: [:create]

  def send_signup_mail
    RegistrationMailer.user_signup(current_user).deliver_later
    AdminMailer.user_signup(current_user).deliver_later
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute, :country_code])
  end

  def set_orders
    @orders = current_user.photo_albums.map do |album|
      album.orders.reject { |order| order.state == 'draft' || order.state == 'draft_canceled' }
    end.flatten
  end
end
