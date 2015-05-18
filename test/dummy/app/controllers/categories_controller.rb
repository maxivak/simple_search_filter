class CategoriesController < ApplicationController

  autocomplete :category, :title

end