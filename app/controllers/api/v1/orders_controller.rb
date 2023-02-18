class Api::V1::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_order, only: [:show, :destroy]

  def index
    @orders = current_user.orders
    render json: @orders, status: :ok
  end

  def show
    render json: @order, status: :ok
  end

  def create
    body = JSON.parse(request.body.read).with_indifferent_access
    order ||= Services::OrderApi.new(request_body: body, order_user: current_user).save_order
    unless order
      order.update_attribute(status: "failed")
      render json: order, status: :unprocessable_entity
    else
      render json: order, status: :ok
    end    
  end

  def destroy
    OrdersApi.new(order_user: current_user).cancel_order(params.fetch(:payment_id).to_i)
    render json: @order, status: :ok
  end

  # def cancel
  #   @order.cancel
  #   render json: @order, status: :ok
  # end

  private

  def find_order
    binding.break
    @errors = []
    @order = Services::OrderApi.new(order_user: current_user).find_order(params[:payment_id])
    binding.break
    raise NoMethodError if @order.nil?
  rescue NoMethodError
    @errors << "Order not found"
    render json: @errors, status: :not_found
  end

  # def destroy
  #   @order = Order.find(params[:id])
  #   @order.destroy
  #   render json: @order, status: :ok
  # end

end
