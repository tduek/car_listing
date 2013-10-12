class AddAttachmentFileToPics < ActiveRecord::Migration
  def self.up
    change_table :pics do |t|
      t.attachment :file
    end
  end

  def self.down
    drop_attached_file :pics, :file
  end
end
