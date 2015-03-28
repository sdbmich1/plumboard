module CategoriesHelper

  # get category path based on record status
  def get_category_path category
    category.new_record? ? categories_path : category
  end

  # enable edit link if allowed
  def show_category_title category
    if can?(:manage_users, @user)  
      link_to category.name_title, edit_category_path(category)
    else 
      link_to category.name_title, category_listings_path(cid: category, loc: @loc), class: 'pixi-link'
    end 
  end

  # set class for category link
  def set_cat_link_class
    @loc.blank? ? 'pixi-cat-link' : 'img-link'
  end

  # get cat type
  def get_cat_type cat
    cat.category_type_code rescue nil
  end
end
