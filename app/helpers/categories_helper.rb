module CategoriesHelper

  # get category path based on record status
  def get_category_path
    @category.new_record? ? categories_path : @category
  end
end
