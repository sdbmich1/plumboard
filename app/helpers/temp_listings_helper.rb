module TempListingsHelper
  # set promo code for free order if appropriate
  def set_promo_code site
    PIXI_KEYS['pixi']['launch_promo_cd'] if Listing.free_order?(site)
  end

  def msg
    'Are you sure? All your changes will be lost.'
  end

  def photo_msg
    'Image will be removed. Are you sure?'
  end

  def add_photo(form_builder)
    link_to_function("add", :id => "add_photo") do |page|
      form_builder.fields_for :pictures, Picture.new, :child_index => 'NEW_RECORD' do |photo_form|
	html = render(:partial => 'pixi_photo', :locals => { :f => photo_form })
        page << "$('add_photo').insert({ before: '#{escape_javascript(raw html)}'.replace(/NEW_RECORD/g, new Date().getTime()) });"
      end
    end
  end

  def delete_photo(form_builder)
    if form_builder.object.new_record?
      link_to_function("Remove Image", "this.up('fieldset').remove()")
    else
      form_builder.hidden_field(:_destroy) +
        link_to_function("Remove Image", "this.up('fieldset').hide(); $(this).previous().value = '1'")
    end
  end
end
