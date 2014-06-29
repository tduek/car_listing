class Stat < ActiveRecord::Base
  attr_accessible :mean, :model_id, :pop, :std_dev, :year

  def self.refresh
    Year.first(5).each do |year|
      Stat.connection.execute(<<-SQL)
        INSERT INTO stats (model_id, year, pop, mean, std_dev, updated_at, created_at)
        SELECT '#{ year.model_id }',
               '#{ year.year }',
               count(listings.id),
               avg(listings.price),
               (CASE WHEN count(listings.id) >= 30 THEN stddev_samp(listings.price) ELSE NULL END),
               '#{ Time.now.to_s(:db) }',
               '#{ Time.now.to_s(:db) }'
        FROM years
        INNER JOIN subdivisions
        ON subdivisions.id=years.model_id
        INNER JOIN listings
        ON listings.model_id=subdivisions.id
        WHERE years.year='#{ year.year }'
          AND subdivisions.id='#{ year.model_id }'
          AND listings.year='#{year.year}'
          AND listings.model_id='#{ year.model_id }'
        GROUP BY years.year
      SQL
    end
  end
end

#Listing.select('outer_listings.*, (SELECT (sum(case when inner_listings.price < outer_listings.price then 1 else 0 end) / (count(inner_listings.id) * 1.0)) as deal_percentage FROM listings as inner_listings WHERE inner_listings.year=outer_listings.year AND inner_listings.model_id=outer_listings.model_id)').from('listings AS outer_listings')

#Listing.select('outer_listings.*, (sum(CASE WHEN inner_listings.price > outer_listings.price THEN 1 ELSE 0 END) / (count(inner_listings.*) * 1.0)) AS deal_ratio').from('listings AS outer_listings').joins('LEFT OUTER JOIN listings AS inner_listings ON outer_listings.year=inner_listings.year AND outer_listings.model_id=inner_listings.model_id').group('outer_listings.id')
