class AddDetailsToDistanceQuery < ActiveRecord::Migration
  def change
    add_column :distance_queries, :first_name, :string
    add_column :distance_queries, :last_name, :string
    add_column :distance_queries, :ip_address, :string
  end
end
