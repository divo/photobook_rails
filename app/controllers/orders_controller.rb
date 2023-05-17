class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin

  def verify
    @order = Order.find(params[:order_id])
    respond_to do |format|
      format.html { render :verify }
    end
  end

  def verify_order
    @order = Order.find(params[:order_id])

    if @order.rendered?
      @order.verify!
      msg = 'Order was successfully verified.'
    else
      msg = 'Order was in invalid state: ' + @order.state
    end

    @order.save
    respond_to do |format|
      format.html { redirect_to verify_order_path(@order), notice: msg }
    end
  end

  private

  def verify_admin
    unless current_user.admin?
      redirect_to root_path
    end
  end
end
