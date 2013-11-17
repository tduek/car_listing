class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      redirect_to @user, notice: "You're in the system now!"
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      redirect_to @user, notice: "Saved changes!"
    else
      flash[:alert] = "Couldn't save changes. Check below."
      render :edit
    end
  end

  def destroy
    @user.find(params[:id]).deactivate!

    redirect_to root_url, notice: "Account deactivated!"
  end
end
