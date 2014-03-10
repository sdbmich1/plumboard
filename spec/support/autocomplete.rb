def old_fill_autocomplete(item_text, input_selector="input[data-autocomplete]")
    page.execute_script %Q{ $('#{input_selector}').trigger("focus") }
    page.execute_script %Q{ $('#{input_selector}').trigger("keydown") }
    # page.execute_script "$('#{input_selector}').focus().keydown()"
    
    sleep 3
    # Set up a selector, wait for it to appear on the page, then use it.
    # item_selector = "ul.ui-autocomplete li.ui-menu-item a:contains('#{item_text}')"
    item_selector = ".ui-menu-item a:contains('#{item_text}')"
     
    # page.should have_selector item_selector
    page.execute_script %Q{ $("#{item_selector}").trigger("mouseenter").trigger("click"); }
    # page.execute_script("$('.ui-menu-item a:contains(\"#{item_text}\")').trigger('mouseenter').click()")
end

def fill_autocomplete(field, options = {})
  fill_in field, with: options[:with]

  page.execute_script %Q{ $('##{field}').trigger('focus') }
  page.execute_script %Q{ $('##{field}').trigger('keydown') }
  selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}

  page.should have_selector('ul.ui-autocomplete li.ui-menu-item a')
  page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
end
