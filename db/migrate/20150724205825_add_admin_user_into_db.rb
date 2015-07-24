class AddAdminUserIntoDb < ActiveRecord::Migration
  def up
    User.create(name: "Global Admin", email: "admin@admin.com", password: 'gonzalez123')
  end

  def down
    User.delete_all
  end
end
