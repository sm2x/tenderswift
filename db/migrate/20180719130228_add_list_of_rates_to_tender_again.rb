class AddListOfRatesToTenderAgain < ActiveRecord::Migration[5.1]
  def change
    add_column :tenders, :list_of_rates, :jsonb, default: {}
  end
end
