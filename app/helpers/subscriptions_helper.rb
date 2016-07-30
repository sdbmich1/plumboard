module SubscriptionsHelper
  def get_sub_path
    if action_name == 'new'
      new_subscription_path
    else
      subscriptions_path(adminFlg: adminMode?)
    end
  end

  def show_sub_menu
    if @user.is_business? || adminMode?
      content_tag(:li,
        link_to('Subscription', get_sub_path, class: 'submenu', remote: true),
        class: controller_name == 'subscriptions' ? 'active' : '')
    end
  end

  def show_sub sub
    if sub
      render partial: 'shared/show_sub', locals: { sub: sub }
    else
      content_tag(:div, 'Subscription not found.', class:'center-wrapper mtop')
    end
  end
end
