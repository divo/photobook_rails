# Create orders with Gelato
class OrderClient
  include HTTParty
  include Gelato

  def initialize(order_ref, user, item_ref)
    @order_ref = order_ref
    @user = user
    @item_ref = item_ref
  end

  def quote(page_count)
    self.class
        .post(QUOTE_URL,
              body: quote_params(@order_ref, @user, @item_ref, page_count).to_json,
              headers: {
                'Content-Type' => 'application/json'
              }.merge(api_key_header))
  end
end
