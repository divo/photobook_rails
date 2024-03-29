class RegistrationMailer < ApplicationMailer
  def user_signup(user)
    @user = user
    mail(to: @user.email,
         subject: 'Welcome to the Mementos.ink',
         from: Rails.application.credentials.dig(:smtp, :username),
         reply_to: Rails.application.credentials.dig(:smtp, :username),
         template_name: 'user_signup')
  end

  def user_delete(user)
    @user = user
    mail(to: @user.email,
         subject: 'You Mementos.ink account was deleted',
         from: Rails.application.credentials.dig(:smtp, :username),
         reply_to: Rails.application.credentials.dig(:smtp, :username),
         template_name: 'user_delete')
  end
end
