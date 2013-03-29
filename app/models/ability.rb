class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.has_role? :admin
      can :manage, :all
      can :manage_items, User
      can :manage_orders, User
      can :manage_users, User
      can :view_dashboard, User
    else
      can :read, :all

      can :create, Post
      can :update, Post do |post|
        post.try(:user) == user || user.role?(:editor)
      end

      can :create, TempListing
      can :update, TempListing do |listing|
        listing.try(:user) == user || user.role?(:editor)
      end
      can :delete, TempListing do |listing|
        listing.try(:user) == user
      end

      can :delete, Listing do |listing|
        listing.try(:user) == user
      end

      if user.has_role? :editor
        can :manage_items, User
        can :manage_orders, User
        can :view_dashboard, User
      end

      if user.has_role? :subscriber
        can :view_dashboard, User
      end
    end
  end
end
