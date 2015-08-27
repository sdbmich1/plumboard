class AfterCollegeFeed < LoadNewsFeed
  def initialize
    @feed = Feed.find_by_url("https://www.aftercollege.com/exports/pixiboard.zip")
    @category = Category.find_by_name("Jobs")
    @user_image = "aftercollege.png"
    @user_email = "support@aftercollege.com"
    load!
    @doc = nil    # save memory since @doc is very large
  end

  # Check for existence by ref_id instead of title
  def add_listing(n)
    return nil if Listing.exists?(ref_id: @ref_id_xpath[n].text)
    super(n, true)
  end

  # No need to remove images since none of the descriptions have them
  def get_description(n)
    @description_xpath[n].text
  end

  # Add 'Education' and 'Experience' sections
  def process_description(description, n)
    experience, education = @experience_xpath[n].text, @education_xpath[n].text
    description += "\n\nExperience: " + experience unless experience.blank?
    description += "\n\nEducation: " + education unless education.blank?
    super(description, n)
  end

  # Don't look for emails in the description -- the user should always be After College
  def get_email_from_description(description, item_text)
    nil
  end

  # Search for image in title, not description.
  def get_img_loc_text(n)
    @title_xpath[n].text
  end

  # Get the stock image
  def add_image(pic, img_loc_text, stock_images=nil)
    pic.photo = File.open(Rails.root.join('db', 'images', get_stock_image(img_loc_text, stock_images)))
    pic
  end

  # Scan for each word in the stock image title to get a set of words,
  # and then call get_image_from_set
  def get_stock_image(title_text, stock_images)
    title_text.gsub!(/[^0-9a-z ]/i, '')   # remove non-alphanumeric characters
    keywords_in_title = Set.new
    stock_images.keys.each do |title|
      words = title.split(' / ')
      words.each do |word|
        valid_words = [word, word.downcase, word.capitalize, word.pluralize].uniq
        valid_words.each do |valid_word|
          keywords_in_title.add(word) if title_text.include?(valid_word)
        end
      end
    end
    get_image_from_set(keywords_in_title, title_text, stock_images)
  end

  # Given a set of words found in a job title, find a corresponding stock image
  def get_image_from_set(words, title_text, stock_images)
    if words.count == 0
      stock_images['other']
    elsif words.count == 1
      stock_images[words.first]
    else
      handle_multiple_keywords(words, title_text, stock_images)
    end
  end

  # Determine which stock image to use when there's more than one keyword in the title
  def handle_multiple_keywords(words, title_text, stock_images)
    # If all words have the same stock image, return that stock image
    possible_stock_images = Set.new
    words.each { |word| possible_stock_images.add(stock_images[word]) }
    return possible_stock_images.first if possible_stock_images.count == 1
    # If one word appears more frequently than the others, return the stock image for that word
    word = get_most_frequent_word(words, title_text)
    return stock_images[word] if word
    # Remove less descriptive words until all words have the same stock image.
    # For example, {'Medical', 'Assistant'} should be classified as 'Medical', not 'Assistant'.
    words_to_remove = %w(Assistant Intern Manager Support)
    while words.count > 1 && !words_to_remove.empty?
      word = words_to_remove.shift
      words.delete(word)
      # Check if all remaining words have the same stock image
      possible_stock_images.delete(stock_images[word])
      return possible_stock_images.first if possible_stock_images.count == 1
    end
    # If there's still a conflict, use the word that appears first in the title.
    title_words = title_text.split
    title_words.each do |title_word|
      words.each do |word|
        valid_words = get_valid_words(word)
        valid_words.each do |valid_word|
          return stock_images[word] if title_word == valid_word
        end
      end
    end
    # If that fails, return the default image
    'werehiring.jpg'
  end

  # Check if one word appears more frequently than the others
  def get_most_frequent_word(words, title_text)
    word_counts = Hash.new
    words.each { |word| word_counts[word] = title_text.scan(word).count }
    if word_counts.values.count(word_counts.values.max) == 1
      word_counts.max_by { |_, v| v }.first
    else
      nil
    end
  end

  # Return all valid forms of the word provided
  def get_valid_words(word)
    [word, word.downcase, word.capitalize, word.pluralize].uniq
  end

  # Return the Site ID corresponding to the job posting's city.
  # Create the Site if it does not already exist.
  def get_site_id(n)
    if (site = Site.find_by_name(@city_xpath[n].text))
      if site.contacts.first.state == @state_xpath[n].text
        site.id
      else
        add_site(n, [@city_xpath[n].text, @state_xpath[n].text].join(', '))
      end
    else
      add_site(n, @city_xpath[n].text)
    end
  end

  # Save site to database
  def add_site(n, site_name)
    site = Site.new(name: site_name, org_type: 'city', status: 'active')
    lat, lng = Geocoder.coordinates(@zip_xpath[n].text)
    site.contacts.build(city: @city_xpath[n].text, state: @state_xpath[n].text,
      zip: @zip_xpath[n].text, country: @country_xpath[n].text, lat: lat, lng: lng)
    site.save ? site.id : nil
  end

  # Delete all Listing records with ref_ids that are in the database but are not
  # in the feed, as they are no longer posted on AfterCollege.
  def delete_expired_jobs
    ref_ids_in_db = Set.new(Listing.where('ref_id IS NOT NULL').pluck(:ref_id))
    ref_ids_in_feed = Set.new(@ref_id_xpath.map(&:text).map(&:to_i))
    Listing.where(ref_id: (ref_ids_in_db - ref_ids_in_feed).to_a).update_all("status = 'expired'")
  end
end