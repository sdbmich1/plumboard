class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    alias_action :create, :read, :update, :destroy, :to => :crud

    if user.has_role? :admin
      can :manage, :all
      can :manage, PixiPost
      can :manage, Category
      can :manage, Transaction
      can :manage, Invoice
      can :manage, User
      can :access, '/pending_listings'
      can :manage_items, User
      can :manage_orders, User
      can :manage_users, User
      can :view_dashboard, User
    else
      can :read, :all
      can [:read, :update], User do |usr|
        usr.try(:user) == user
      end

      can :read, Category
      can [:create, :show], Transaction, :user_id => user.id

      can [:create, :read, :update], Post do |post|
        post.try(:user) == user
      end

      can :crud, TempListing do |listing|
        listing.try(:user) == user
      end

      can [:crud, :sent], Invoice, :seller_id => user.id
      can [:show, :received], Invoice, :buyer_id => user.id

      can :crud, BankAccount do |acct|
        acct.try(:user) == user
      end

      can :crud, CardAccount do |acct|
        acct.try(:user) == user
      end

      can :update, Listing do |listing|
        listing.try(:user) == user
      end

      if user.has_role? :editor
        can [:read, :update], TempListing, status: 'pending'
        can :access, '/pending_listings'
        can :manage, PixiPost
        can :manage_items, User
        can :manage_orders, User
        can :view_dashboard, User
      end

      if user.has_role? :pixter
        can [:read, :update], PixiPost, status: 'scheduled'
      end

      if user.has_role? :subscriber
        can :view_dashboard, User
      end
    end
  end
end
