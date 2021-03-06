class CreateFileIndices < ActiveRecord::Migration
  def self.up
    create_table :file_indices do |t|
      t.string :snapname
      t.string :basepath
      t.integer :schedule_id
      t.integer :host_id
      t.binary :data
      t.timestamps
    end
  end

  def self.down
    drop_table :file_indices
  end
end
