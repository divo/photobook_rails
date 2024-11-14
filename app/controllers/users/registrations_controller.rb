# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :account_update_params, only: [:update]
  prepend_before_action :validate_cloudflare_turnstile, only: [:create]

  before_action :set_orders, only: %i[show edit]
  after_action :send_signup_mail, only: [:create]

  def send_signup_mail
    RegistrationMailer.user_signup(resource).deliver_later
    AdminMailer.user_signup(resource).deliver_later
  end

  def destroy
    resource.email = "#{resource.email}_deleted_#{Time.now.to_i}"
    resource.soft_delete
    resource.send_deletion_email
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_navigational_format?
    respond_with_navigational(resource) { redirect_to after_sign_out_path_for(resource_name) }
  end

  def validate_cloudflare_turnstile
    validation = TurnstileVerifier.check(params[:"cf-turnstile-response"], request.remote_ip)
    return if validation

    # If validation fails, we set our resource since this code is executed
    # in a `prepend_before_action`
    self.resource = resource_class.new sign_up_params
    resource.validate
    set_minimum_password_length
    respond_with_navigational(resource) { render :new }
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[attribute country_code])
  end

  def set_orders
    @orders = current_user.photo_albums.map do |album|
      album.orders.reject { |order| order.state == 'draft' || order.state == 'draft_canceled' }
    end.flatten
  end
end
