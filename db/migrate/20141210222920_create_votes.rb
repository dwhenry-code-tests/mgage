class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :campaign, index: true
      t.string :choice
      t.integer :votes
      t.integer :invalid_votes

      t.timestamps
    end
  end
end
