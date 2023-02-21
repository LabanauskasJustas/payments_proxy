# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      before_action :authenticate_user!, :json_params
      before_action :find_order, only: %i[show destroy]

      def index
        @orders = current_user.orders
      end

      def show
      end

      def create
        body = JSON.parse(request.body.read).with_indifferent_access
        @order ||= Services::OrderApi.new(request_body: body, order_user: current_user).save_order
      rescue KeyError => e
        @errors << 'Failed to create order'
        @messages << e.message
        render '404', status: :unprocessable_entity
      end

      def destroy
        Services::OrderApi.new(order_user: current_user, order: @order).cancel_order
      end

      private

      def json_params
        @errors = []
        @messages = []
      end

      def find_order
        @errors = []
        @order = Services::OrderApi.new(order_user: current_user).find_order(params.fetch(:order_id))
        raise NoMethodError if @order.nil?
      rescue NoMethodError
        @errors << 'Order not found'
        render '404', status: :not_found
      end
    end
  end
end
