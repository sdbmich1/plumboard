module CategoriesHelper

  # get category path based on record status
  def get_category_path
    @category.new_record? ? categories_path : @category
  end

  # set pixi link
  def pixi_link category, loc
    cnt = category.active_pixis_by_site(loc).size
    if cnt > 0
      link_to "(#{cnt})", '#', class: 'pixi-cat', 'data-cat-id'=> category.id
    else
      "(#{cnt})"
    end
  end
end
