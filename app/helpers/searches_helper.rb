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
end
