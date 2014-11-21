class AddLatitudeAndLongitudeToDistanceQuery < ActiveRecord::Migration
  def change
    add_column :distance_queries, :latitude, :float
    add_column :distance_queries, :longitude, :float
  end
end
