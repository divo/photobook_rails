# Create orders with Gelato
class OrderClient
  include HTTParty
  include Gelato


  def quote(order_ref, customer, item_ref, page_count)
    self.class.post(QUOTE_URL,
                    body: quote_params(order_ref, customer, item_ref, page_count).to_json,
                    headers: {
                      'Content-Type' => 'application/json'
                    }.merge(api_key_header))
  end
end
