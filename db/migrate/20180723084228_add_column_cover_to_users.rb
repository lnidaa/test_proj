class AddColumnCoverToUsers < ActiveRecord::Migration[5.2]
  def up
    add_attachment :users, :cover
  end

  def down
    remove_attachment :users, :cover
  end
end
