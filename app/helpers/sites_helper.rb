module SitesHelper
  # toggle between creating and updating in Site form
  def create_or_update_path(site)
    action_name == 'new' ? sites_path  : site_path(@site)
  end

  # navbar links are only remote on Manage Sites and Create Site
  def toggle_remote
    %w(index new).include?(action_name)
  end

  # display profile photo if the site has one
  def toggle_profile_photo(site)
    if site.pictures.count > 1
      photo = show_photo(site, 0, set_profile_photo(false), '80x80', false)
      content_tag(:div, photo, class: 'xlg-top span2')
    end
  end
end
