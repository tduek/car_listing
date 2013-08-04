module CraigslistCarScraper
  include Timeout
  
  def start(seller_type = "o")
    CraigsSite.select("id, city_for_url").all.each do |city|
      page_num = 0
      @scraped_new_listings_from_page = true
      while @scraped_new_listings_from_page && page_num <= 25
        srch_page_url = build_srch_page_url(city.city_for_url, seller_type, page_num) 
        scrape_paginated_srch_page(srch_page_url, city.id, seller_type)
        
        page_num += 1
      end
    end
    start("d") if seller_type == "o"
  end
  
  
  private
  
  def scrape_paginated_srch_page(url, city_id, seller_type, attempt = 0)
    @scraped_new_listings_from_page = false
    begin
      Timeout::timeout(90) do
        doc = Nokogiri::HTML(open(url.to_s))
    
        doc.css(".row").each do |row|
          guid = row.at_css("a")[:href][/\d{6,}/]
          if !exists?(guid: guid) && !dq_text?(row.at_css("a").text, city_id, seller_type, guid)
            listing_url = url.dup
            listing_url.path, listing_url.query = row.at_css("a")[:href], nil
        
            scrape_listing_details_page(listing_url, city_id, seller_type, guid, row)
          end
        end
      end
    rescue
      scrape_paginated_srch_page(url, city_id, seller_type, attempt+1) if attempt < 3
    end
  end
  
  
  def scrape_listing_details_page(url, city_id, seller_type, guid, row, attempt = 0)
    begin
      Timeout::timeout(5) do
        page = Nokogiri::HTML(open(url.to_s))
    
        body = page.css("#postingbody").text
        post_date = Time.at(page.css('date').last.attributes["title"].value.to_i).to_datetime
    
        unless dq_text?(body, city_id, seller_type, guid)
          Scraping.create(guid: guid,
                craigs_site_id: city_id,
                   seller_type: seller_type,
                         title: row.css("a").text,
                   description: body,
                           url: url.to_s,
                        source: "Craigslist",
                     post_date: post_date)
        end
      end
    rescue
      scrape_listing_details_page(url, city_id, seller_type, guid, row, attempt+1) if attempt < 3
    end
  end
  
  def dq_text?(text, city_id, seller_type, guid)
    @scraped_new_listings_from_page = true
             
             # These have been in accidents
    dqers = ['rebuil', 'salvag', 'salvaj', 'rebil', 'ribil', 'flood', 
             'damage', 'repair', 'export', 'hit',
             # These are financed. Advertised price may be down payment.
             'over payment', 'take over', 'payments', 'dwn', 'down', 'credit', 
             'financ', 'approv', 'payment', 'take over', 'lease', 'pay here',
             # These are miscategorized.
             'golf cart', 'kawasaki', 'fourwheeler', 'atv', 
             'brute force', 'replica', 'yamaha', 'bike', 'rincon', 'triumph']
  
    dqers.each do |dqer|
      if text[/#{dqer}/]
        Scraping.create(guid: guid, 
              craigs_site_id: city_id, 
                 seller_type: seller_type,
                      source: "Craigslist",
                        dqed: true)
        return true
      end
    end
   
    false
  end
    
  
  def build_srch_page_url(city_for_url, seller_type, page_num)
    url = URI.parse("http://city.craigslist.org/search/ct#{seller_type}/")
    
    url.host.gsub!(/\A\w+/, city_for_url)
    
    car_yrs = "(#{(Time.now.year-10..Time.now.year).to_a.map { |yr| 
      [yr, (yr-2000).to_s.rjust(2, "0")] }.join("|")})"
    
    url.query = URI.encode_www_form({"s"        => page_num * 100,
                                     "query"    => car_yrs,
                                     "minAsk"   => 1000,
                                     "maxAsk"   => 500000,
                                     "srchType" => "T"})
    url
  end
end