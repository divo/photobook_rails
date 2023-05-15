class AdminMailer < ApplicationMailer
  def user_signup(user)
    @user = user
    mail(to: Rails.application.credentials.dig(:admin, :email),
         subject: 'New User Signup',
         from: Rails.application.credentials.dig(:smtp, :username),
         reply_to: Rails.application.credentials.dig(:smtp, :username),
         body: "A new user has signed up: #{user.email}",
         content_type: "text/html")
  end

  def order_placed(order)
    @order = order
    mail(to: Rails.application.credentials.dig(:admin, :email),
         subject: 'New Order Placed',
         from: Rails.application.credentials.dig(:smtp, :username),
         reply_to: Rails.application.credentials.dig(:smtp, :username),
         body: "An order has been placed: #{order.id}",
         content_type: "text/html")
  end

  def order_failed(order)
    @order = order
    mail(to: Rails.application.credentials.dig(:admin, :email),
         subject: '⚠️ ⚠️  Order Failed ⚠️ ⚠️',
         from: Rails.application.credentials.dig(:smtp, :username),
         reply_to: Rails.application.credentials.dig(:smtp, :username),
         body: "An order has been failed: #{order.id}",
         content_type: "text/html")
  end
end
