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
  
  def scrape_paginated_srch_page(url, city_id, seller_type)
    @scraped_new_listings_from_page = false
    page = get_page(url.to_s)
    return unless page
    page.css(".row").each do |row|
      
      path = row.at_css("a")[:href]
      guid = path[/\d{6,}/]
      listing_url = url.dup
      listing_url.path, listing_url.query = path, nil
      
      if !exists?(guid: guid) #&& !dq_text?(row.at_css("a").text, city_id, seller_type, guid, listing_url.to_s)
        @scraped_new_listings_from_page = true
        scrape_listing_details_page(listing_url, city_id, seller_type, guid, row)
      end
    end
  end
  
  def scrape_listing_details_page(url, city_id, seller_type, guid, row, attempt = 0)
    page = get_page(url.to_s)
    return unless page
    body = page.css("#postingbody").text
    # the listing won't have a 
    post_date = page.css("date").last
    post_date = post_date ? Time.at(post_date.attributes["title"].value.to_i).to_datetime : nil


    scraping = Scraping.create(guid: guid,
                     craigs_site_id: city_id,
                        seller_type: seller_type,
                              title: row.css("a").text,
                        description: body,
                                url: url.to_s,
                             source: "Craigslist",
                          post_date: post_date,
                              price: row.css(".price").text[/\d+/].to_i,
                               dqed: !post_date)
    scrape_pics(page, scraping) 
  end
  
  def scrape_pics(page, scraping)
    page.css("#thumbs a").each do |link|
      main_pic = scraping.main_pics.create(src: link[:href], is_thumb: false)
      scraping.thumbs.create(src: link.at_css("img")[:src],
                       thumb_for: main_pic.id,
                        is_thumb: true)
    end
  end
  
  def get_page(url, secs = 5, i = 0)
    begin
      timeout(secs) { Nokogiri::HTML(open(url)) }
    rescue
      get_page(url, secs, i+1) if i < 2
    end
  end
  
  def build_srch_page_url(city_for_url, seller_type, page_num)
    url = Addressable::URI.parse(
                      "http://city.craigslist.org/search/ct#{seller_type}/")
    
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
  
  def dq_text?(text, city_id, seller_type, guid, url)
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
      if text[/#{dqer}/i]
        Scraping.create(guid: guid, 
              craigs_site_id: city_id, 
                 seller_type: seller_type,
                      source: "Craigslist",
                        dqed: true,
                         url: url)
        return true
      end
    end
   
    false
  end
  
end