class AddForeignUserPermissions < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute(<<-SQL)
        CREATE USER blackie_dev WITH PASSWORD '12345678';

        GRANT SELECT, UPDATE, INSERT, DELETE ON subdivisions TO blackie_dev;
        GRANT SELECT, UPDATE, INSERT, DELETE ON years TO blackie_dev;
        GRANT SELECT, UPDATE, INSERT, DELETE ON users TO blackie_dev;
        GRANT SELECT, UPDATE, INSERT, DELETE ON pics TO blackie_dev;
        GRANT SELECT, UPDATE, INSERT, DELETE ON listings TO blackie_dev;

      SQL
    end
  end

  def down
    if Rails.env.development?
      execute(<<-SQL)
        REVOKE SELECT, UPDATE, INSERT, DELETE ON subdivisions TO blackie_dev;
        REVOKE SELECT, UPDATE, INSERT, DELETE ON years TO blackie_dev;
        REVOKE SELECT, UPDATE, INSERT, DELETE ON users TO blackie_dev;
        REVOKE SELECT, UPDATE, INSERT, DELETE ON pics TO blackie_dev;
        REVOKE SELECT, UPDATE, INSERT, DELETE ON listings TO blackie_dev;

        DROP ROLE blackie_dev;
      SQL
    end
  end
end
