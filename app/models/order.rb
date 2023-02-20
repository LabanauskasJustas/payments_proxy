# frozen_string_literal: true

class Order < ApplicationRecord
  acts_as_paranoid

  before_destroy :cancel
  belongs_to :user
  serialize :TransactionHash, Hash

  def cancel
    update(status: 'cancelled')
    touch :canceled_at
  end
end
