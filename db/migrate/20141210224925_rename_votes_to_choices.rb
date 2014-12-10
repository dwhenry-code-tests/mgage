class RenameVotesToChoices < ActiveRecord::Migration
  def change
    rename_table :votes, :choices
    rename_column :choices, :choice, :name
  end
end
