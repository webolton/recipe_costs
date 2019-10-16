class IngredientsController < ApplicationController
  def index
    @ingredients = Ingredient.all
  end

  # Ingredient import page
  def import
    Ingredient.import(params[:file])
    redirect_to ingredients_index_path, notice: "File successfully imported"
  end
end
