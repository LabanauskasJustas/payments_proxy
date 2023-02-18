class Order < ApplicationRecord
  acts_as_paranoid

  before_destroy :cancel
  belongs_to :user
  serialize :TransactionHash, Hash

  def cancel
    update_attribute(status: "cancelled")
  end
end
