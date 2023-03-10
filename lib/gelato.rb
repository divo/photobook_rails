module Gelato
  QUOTE_URL = 'https://order.gelatoapis.com/v4/orders:quote'.freeze
  SOFTCOVER_UUID = 'photobooks-softcover_pf_200x200-mm-8x8-inch_pt_170-gsm-65lb-coated-silk_cl_4-4_ccl_4-4_bt_glued-left_ct_matt-lamination_prt_1-0_cpt_250-gsm-100-lb-cover-coated-silk_ver'.freeze

  def api_key_header
    { 'X-API-KEY' => Rails.application.credentials[:gelato_api_key] }
  end

  def quote_params(order_ref, customer, item_ref, page_count)
    {
      orderReferenceId: order_ref,
      customerReferenceId: customer.ref,
      currency: 'EUR',
      allowMultipleQuotes: false,
      recipient: {
        "country": customer.country
      },
      products: [
        {
          itemReferenceId: item_ref,
          productUid: SOFTCOVER_UUID,
          quantity: 1,
          pageCount: page_count,
          files: [
            type: 'default',
            url: 'https://s3-eu-west-1.amazonaws.com/developers.gelato.com/product-examples/test_print_job_BX_4-4_hor_none.pdf'
          ]
        }
      ]
    }
  end
end
