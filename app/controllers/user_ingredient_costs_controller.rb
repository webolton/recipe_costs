class UserIngredientCostsController < ApplicationController
  before_action :require_login
  # before_action :redirect_non_users
  before_action :set_variables

  # All records
  def index
    # redirect_to ingredients_path if is_admin?
    if authorize(@user)
      @user_ingredient_costs = @user.user_ingredient_costs.order(name: :asc)
      @ingredients = Ingredient.all.order(name: :asc)
    end
  end

  # Display new form
  def new
    if authorize(@user)
      @user_ingredient_cost = @user.user_ingredient_costs.build()
    end
  end

  # Create record
  def create
    if authorize(@user)
      # Create ingredient
      @user_ingredient_cost = @user.user_ingredient_costs.build(params.require(:user_ingredient_cost).permit(:ingredient_id, :cost, :cost_size, :cost_unit))

      # Redirect unless error
      if @user_ingredient_cost.save
        flash[:success] = "Success! #{@user_ingredient_cost.ingredient.name.titleize} created."
        redirect_to user_ingredients_path(@user)
      else
        render :new
      end
    end
  end

  # Display record
  def show
    # redirect_to ingredients_path if is_admin?
    if authorize(@user)

      # Find record
      @user_ingredient_cost = @user.user_ingredient_costs.find_by(id: params[:id])

      # Redirect if error
      redirect_to user_ingredients_path(@user), alert: "Custom cost not found." if @user_ingredient_cost.nil?
    end
  end

  # Display edit form
  def edit
    if authorize(@user)
      # Find record
      @user_ingredient_cost = @user.user_ingredient_costs.find_by(id: params[:id])

      # Redirect if error
      redirect_to user_ingredients_path(@user), alert: "Custom cost not found." if @user_ingredient_cost.nil?
    end
  end

   # Update record
  def update
    if authorize(@user)
      # Find and update record
      @user_ingredient_cost = @user.user_ingredient_costs.find(params[:id])
      @user_ingredient_cost.update(params.require(:user_ingredient_cost).permit(:cost, :cost_size, :cost_unit))

      # Redirect unless error
      if @user_ingredient_cost.save
        flash[:success] = "Success! #{@user_ingredient_cost.ingredient.name.titleize} updated."
        redirect_to user_ingredients_path(@user)
      else
        render :edit
      end
    end
  end

  # Delete record
  def destroy
    if authorize(@user)
      # Find record
      user_ingredient_cost = @user.user_ingredient_costs.find_by(id: params[:id])
      
      # Destroy unless error
      if user_ingredient_cost
        flash[:success] = "Success! #{user_ingredient_cost.ingredient.name.titleize} deleted."
        user_ingredient_cost.destroy
      else
        flash[:alert] = "Custom cost not found."
      end

      redirect_to user_ingredients_path(@user)
    end
  end

  private

  def set_variables
    @user = User.find_by(id: params[:user_id])
    @units = available_units  
  end

  def ing_params
    params.require(:user_ingredient_cost).permit(:cost, :cost_size, :cost_unit)
  end

end
