class CreateViewsForIdSequences < ActiveRecord::Migration
  def up
    execute(<<-SQL)
      -- subdivisions
      CREATE VIEW subdivisions_id_seq_view AS SELECT nextval('subdivisions_id_seq') AS next_id;

      -- years
      CREATE VIEW years_id_seq_view AS SELECT nextval('years_id_seq') AS next_id;

      -- users
      CREATE VIEW users_id_seq_view AS SELECT nextval('users_id_seq') AS next_id;

      -- listings
      CREATE VIEW listings_id_seq_view AS SELECT nextval('listings_id_seq') AS next_id;

      -- pics
      CREATE VIEW pics_id_seq_view AS SELECT nextval('pics_id_seq') AS next_id;

    SQL
  end

  def down
    execute(<<-SQL)
      DROP VIEW IF EXISTS subdivisions_id_seq_view;
      DROP VIEW IF EXISTS years_id_seq_view;
      DROP VIEW IF EXISTS users_id_seq_view;
      DROP VIEW IF EXISTS listings_id_seq_view;
      DROP VIEW IF EXISTS pics_id_seq_view;
    SQL
  end
end
