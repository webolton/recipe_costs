class UsersController < ApplicationController
  before_action :require_login
  skip_before_action :require_login, only: [:new, :create]

  # Display all users
  def index
    if is_admin?
      @users = User.all.order(name: :asc)
    else
      return head(:forbidden)
      # redirect_to root_path, error: "You're not authorized to see this resource."
    end
  end

  # Display user page
  def show
    @user = User.find(params[:id])
    # Redirect if not user or admin  
    require_authorization(@user)
  end

  # Display signup form
  def new
    @user = User.new
  end

  # Display edit form
  def edit
    @user = User.find(params[:id])
    require_authorization(@user)
  end
  
  # Create user
  def create
    params[:user][:admin] = "true" if params[:user][:admin] && params[:user][:admin] == "1"

    @user = User.new(user_params)
    if @user.save
      # Set session if current user isn't an admin
      if is_admin?
        redirect_to users_path, notice: "#{@user.name} successfully created."
      else 
        session[:user_id] = @user.id
        redirect_to user_path(@user)
      end
    else
      flash[:error] = @user.errors.full_messages
      redirect_to new_user_path
      # redirect_to new_user_path, error: "Credentials don't work. Please ensure your passwords match."
    end
  end
 
  # Edit user
  def update
    params[:user][:admin] = "true" if params[:user][:admin] && params[:user][:admin] == "1"

    @user = User.find(params[:id])

    # Ensure edits are made by owner or admin user
    if user_authorized?(@user)
      @user.update(user_params)
      if @user.save
        # Set session if current user isn't an admin
        if @user == current_user
          redirect_to @user, notice: "Success! You're updated."
        else 
          redirect_to users_path, notice: "#{@user.name} successfully updated."
        end
      else
        flash[:error] = @user.errors.full_messages
        # flash[:error] = "Credentials don't work. Please ensure your passwords match."
        render :edit
      end
    else
      redirect_to root_path, error: "You're not authorized to change this resource."
    end
  end

  # Delete user
  def destroy
    # Ensure only admins can delete users
    if is_admin?
      @user = User.find(params[:id])
      @user.destroy
      flash[:notice] = "User deleted"
      redirect_to users_path
    else
      redirect_to root_path, error: "You're not authorized to change this resource."
    end
  end


  private
 
  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation, :organization, :admin)
  end
  
end