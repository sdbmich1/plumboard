module SearchesHelper

  # get path based on controller
  def get_search_path
    case controller_name
      when 'posts'; post_searches_url
      else searches_url
    end
  end

  # get autocomplete path based on controller
  def get_autocomplete_path
    case controller_name
      when 'posts'; autocomplete_post_content_post_searches_path
      else autocomplete_listing_title_searches_path
    end
  end

  # get partial based on mime type
  def get_partial
    # mobile_device? ? 'mobile/listings' : 'shared/listings'
    'shared/listings'
  end

  # get partial based on mime type
  def get_nxt_pg_partial
    # mobile_device? ? 'mobile/search_next_page' : 'shared/search_next_page'
    'shared/search_next_page'
  end
end
