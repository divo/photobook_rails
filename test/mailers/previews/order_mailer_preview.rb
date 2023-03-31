# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def order_confirmation
    OrderMailer.order_confirmation(Order.first)
  end

  def order_shipped
    OrderMailer.order_shipped(Order.first)
  end
end
