module CategoriesHelper

  # get category path based on record status
  def get_category_path
    @category.new_record? ? categories_path : @category
  end

  # enable edit link if allowed
  def show_category_title category
    if can?(:manage_users, @user)  
      link_to category.name_title, edit_category_path(category)
    else 
      link_to category.name_title, category_path(category), class: 'pixi-link'
    end 
  end
end
