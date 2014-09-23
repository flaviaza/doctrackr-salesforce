class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :sf_reference
      t.string :sf_reference_username
      t.string :refresh_token
      t.string :oauth_token

      t.timestamps
    end
  end
end
