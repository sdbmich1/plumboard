module ShopLocalsHelper

  def set_sls_menu str=[]
    str << link_to('About', '#about', class: 'sls-browse-link') 
    str << link_to('Businesses', '#biz', class: 'mleft20 sls-browse-link') 
    str << link_to('Individuals', '#ind', class: 'mleft20 sls-browse-link') 
    add_signup_link str, 'mleft20 sls-browse-link' 
    content_tag(:div, str.join(" ").html_safe)
  end

  def show_sls_subtitle section, flg
    content_tag(:div, SLS_KEYS[section]['subtitle'], class: 'med-top sls-item-text center-wrapper') if flg
  end

  def show_sls_image fname, cls=''
    content_tag(:div, image_tag(fname, class: 'sls-logo'), class: cls + ' span6 center-wrapper')
  end

  def show_signup_btn flg, tag, section
    rte = section.match(/biz/).nil? ? '#signupDialog' : '#bizDialog'
    cls = 'btn btn-large btn-primary sls-btn'
    content_tag(:div, link_to(tag, rte, "data-toggle" => "modal", class: cls), class: 'big-top center-wrapper') if flg
  end

  def get_section_class section
    case section
      when 'join'; 'offset1 span5 sls-vline' 
      when 'biz_join'; 'span5'
      when 'ind'; 'offset1 span5'
      else 'span6'
    end
  end

  def set_signup_btn_id id
    id.match(/biz/).nil? ? 'signup-email-btn' : 'biz-signup-email-btn'
  end

  def set_close_btn_id id
    id.match(/biz/).nil? ? 'signup-close-btn' : 'biz-signup-close-btn'
  end

  def set_sls_subtitle str=[]
    title = SLS_KEYS['home']['subtitle'] 
    str << title[0..title.length-3]
    str << content_tag(:span, title[title.length-2..title.length], class: 'sls-sup')
    content_tag(:div, str.join('').html_safe, class: 'sls-subtitle')
  end

  def set_sls_logo fname, cls, path, title
    content_tag(:div, link_to(image_tag(fname, class: 'sls-small-logo'), path, class: 'img-link'), class: cls)
  end
end
