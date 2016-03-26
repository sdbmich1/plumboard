class ConfirmationsController < Devise::ConfirmationsController

  def create
    @user = User.where(:email => params[:user][:email]).first

    if @user && @user.confirmed_at.nil?
      UserMailer.confirmation_instructions(@user).deliver_later
      flash[:notice] = t("devise.registrations.signed_up_but_unconfirmed") 
      redirect_to root_url
    else
      super
    end
  end
end
