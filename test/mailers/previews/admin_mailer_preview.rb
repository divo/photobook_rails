class AdminMailerPreview < ActionMailer::Preview
  def order_verification
    AdminMailer.order_verification(Order.first)
  end
end
