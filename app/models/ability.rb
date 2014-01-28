class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.has_role? :admin
      can :manage, :all
      can :manage, Category
      can :access, '/pending_listings'
      can :manage_items, User
      can :manage_orders, User
      can :manage_users, User
      can :view_dashboard, User
    else
      can :read, :all

      can [:create, :read], Transaction do |txn|
        txn.try(:user) == user
      end

      can [:create, :read, :update], Post do |post|
        post.try(:user) == user
      end

      can [:create, :read, :update, :delete], TempListing do |listing|
        listing.try(:user) == user
      end

      can [:create, :update, :delete], Invoice do |invoice|
        invoice.try(:user) == user
      end

      can :delete, Listing do |listing|
        listing.try(:user) == user
      end

      if user.has_role? :editor
        can [:read, :update], TempListing, status: 'pending'
        can :access, '/pending_listings'
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
