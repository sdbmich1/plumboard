module CategoriesHelper

  # get category path based on record status
  def get_category_path
    @category.new_record? ? categories_path : @category
  end

  # set pixi link
  def pixi_link category, loc
    cnt = category.active_pixis_by_site(loc).size
    "(#{cnt})"
  end

  # enable edit link if allowed
  def show_category_title category
    if can?(:manage_users, @user)  
      link_to category.name_title, edit_category_path(category), remote: true 
    else 
      category.name_title 
    end 
  end
end
