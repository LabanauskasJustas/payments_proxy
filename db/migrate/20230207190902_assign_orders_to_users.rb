# frozen_string_literal: true

class AssignOrdersToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :user, index: true
  end
end
