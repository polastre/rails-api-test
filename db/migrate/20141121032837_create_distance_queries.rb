class CreateDistanceQueries < ActiveRecord::Migration
  def change
    create_table :distance_queries do |t|

      t.timestamps
    end
  end
end
