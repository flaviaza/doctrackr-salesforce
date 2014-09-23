class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :name
      t.integer :dt_reference, limit: 8
      t.string :sf_reference
      t.datetime :last_event_at

      t.timestamps
    end
  end
end
