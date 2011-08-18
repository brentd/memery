class Initial < ActiveRecord::Migration
  def self.up
    create_table :memes do |t|
      t.string :image_url
      t.integer :width
      t.integer :height
      t.string :top
      t.string :bottom
    end
  end

  def self.down
    drop_table :memes
  end
end
