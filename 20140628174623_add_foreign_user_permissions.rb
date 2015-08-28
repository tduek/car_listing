class AddForeignUserPermissions < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute(<<-SQL)
        CREATE USER blackie_dev WITH PASSWORD '12345678';

        GRANT SELECT, UPDATE, INSERT, DELETE ON subdivisions TO blackie_dev;
        GRANT SELECT, UPDATE, INSERT, DELETE ON subdivisions_id_seq_view TO blackie_dev;
        GRANT USAGE, SELECT, UPDATE ON subdivisions_id_seq TO blackie_dev;

        GRANT SELECT, UPDATE, INSERT, DELETE ON years TO blackie_dev;
        GRANT SELECT, UPDATE, INSERT, DELETE ON years_id_seq_view TO blackie_dev;
        GRANT USAGE, SELECT, UPDATE ON years_id_seq TO blackie_dev;

        GRANT SELECT, UPDATE, INSERT, DELETE ON users TO blackie_dev;
        GRANT SELECT, UPDATE, INSERT, DELETE ON users_id_seq_view TO blackie_dev;
        GRANT USAGE, SELECT, UPDATE ON users_id_seq TO blackie_dev;

        GRANT SELECT, UPDATE, INSERT, DELETE ON pics TO blackie_dev;
        GRANT SELECT, UPDATE, INSERT, DELETE ON pics_id_seq_view TO blackie_dev;
        GRANT USAGE, SELECT, UPDATE ON pics_id_seq TO blackie_dev;

        GRANT SELECT, UPDATE, INSERT, DELETE ON listings TO blackie_dev;
        GRANT SELECT, UPDATE, INSERT, DELETE ON listings_id_seq_view TO blackie_dev;
        GRANT USAGE, SELECT, UPDATE ON listings_id_seq TO blackie_dev;

        GRANT SELECT ON zips TO blackie_dev;
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
