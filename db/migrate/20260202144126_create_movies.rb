class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :year
      t.string :poster
      t.string :imdb_id
      t.text :plot

      t.timestamps
    end
  end
end
