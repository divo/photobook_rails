class RegistrationMailer < ApplicationMailer
  def user_signup(user)
    @user = user
    mail(to: @user.email,
         subject: 'Welcome to the Mementos.ink',
         from: Rails.application.credentials.dig(:smtp, :username),
         reply_to: Rails.application.credentials.dig(:smtp, :username),
         template_name: 'user_signup')
  end
end
