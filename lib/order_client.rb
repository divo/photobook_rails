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
      .tap { |response| raise "Error: #{response}" unless response.success? }
  end

  def cover_dimensions(page_count)
    self.class
        .get(COVER_URL,
             headers: {
               'Content-Type' => 'application/json'
             }.merge(api_key_header),
             query: { pageCount: page_count } )
        .tap { |response| raise "Error: #{response}" unless response.success? }
  end

  def place_order(order, page_count, currency)
    self.class
        .post(ORDER_URL,
              body: order_params(@order_ref, order, @user, @item_ref, page_count, currency).to_json,
              headers: {
                'Content-Type' => 'application/json'
              }.merge(api_key_header))
      .tap { |response| raise "Error: #{response}" unless response.success? }
  end
end
