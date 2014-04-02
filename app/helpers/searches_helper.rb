module SearchesHelper

  # get path based on controller
  def get_search_path
    case controller_name
      when 'posts'; post_searches_url
      when 'users'; user_searches_url
      else searches_url
    end
  end

  # get autocomplete path based on controller
  def get_autocomplete_path
    case controller_name
      when 'posts'; autocomplete_post_content_post_searches_path
      when 'users'; autocomplete_user_first_name_user_searches_path
      else autocomplete_listing_title_searches_path
    end
  end

  # set place holder name
  def set_placeholder
    case controller_name
      when 'posts'; 'Search Messages'
      when 'inquiries'; 'Search Inquiries'
      when 'users'; 'Search Users'
      else 'Search Pixis'
    end
  end
end
