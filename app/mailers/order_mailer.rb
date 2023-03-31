class OrderMailer < ApplicationMailer
  def order_confirmation(order)
    @order = order
    mail(to: @order.photo_album.user.email,
         subject: 'Order Confirmation',
         from: Rails.application.credentials.dig(:smtp, :username),
         reply_to: Rails.application.credentials.dig(:smtp, :username),
         template_name: 'order_confirmation')
  end

  def order_shipped(order)
    @order = order
    mail(to: @order.photo_album.user.email,
         subject: 'Order Shipped',
         from: Rails.application.credentials.dig(:smtp, :username),
         reply_to: Rails.application.credentials.dig(:smtp, :username),
         template_name: 'order_shipped')
  end
end
