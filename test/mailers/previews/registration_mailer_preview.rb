# Preview all emails at http://localhost:3000/rails/mailers/registration_mailer
class RegistrationMailerPreview < ActionMailer::Preview
  def user_signup
    RegistrationMailer.user_signup(User.first)
  end
end
