class CheckoutController < ApplicationController
  before_action :authenticate_user!

  skip_before_action :verify_authenticity_token, :only => [:create]

  if Rails.env.development?
    DOMAIN = 'http://localhost:3000'
  else
    DOMAIN = 'https://mementos.ink'
  end

  def create
    photo_album = current_user.photo_albums.find(params[:photo_album_id])
    render json: { error: 'Photo album not found' }, status: :not_found and return unless photo_album

    # TODO: Refetch order estimate here as user could have made changes
    order_estimate = photo_album.order_estimate
    render json: { error: 'Order estimate not found' }, status: :internal_server_error and return unless order_estimate

    @session = Stripe::Checkout::Session
                 .create({
                           success_url: "#{DOMAIN}/checkout/success.html",
                           cancel_url: "#{DOMAIN}/checkout/cancel.html",
                           payment_method_types: ['card'],
                           shipping_address_collection: { allowed_countries: [current_user.country_code] },
                           shipping_options: [
                             {
                               shipping_rate_data: {
                                 type: 'fixed_amount',
                                 fixed_amount: {
                                   amount: unit_amount_to_cents(order_estimate.shipping_price),
                                   currency: order_estimate.currency.downcase
                                 },
                                 display_name: order_estimate.shipping_name,
                                 delivery_estimate: {
                                   minimum: { unit: 'day', value: order_estimate.min_delivery_days },
                                   maximum: { unit: 'day', value: order_estimate.max_delivery_days }
                                 }
                               }
                             }
                           ],
                           line_items: [{
                                          price_data: {
                                            product_data: { name: "Album: #{photo_album.name}" },
                                            unit_amount: unit_amount_to_cents(order_estimate.price),
                                            currency: order_estimate.currency.downcase,
                                            tax_behavior: 'exclusive',
                                          },
                                          quantity: 1
                                        }],
                           mode: 'payment',
                           metadata: { photo_album_id: photo_album.id },
                           customer_email: current_user.email,
                         })
    redirect_to @session.url, status: 303, allow_other_host: true
  end

  private

  def unit_amount_to_cents(amount)
    (amount.to_f * 100).to_i
  end
end
