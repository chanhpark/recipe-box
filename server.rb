require 'sinatra'
require 'pry'
require 'pg'

##############################
####### DB CONNECTION ########
##############################

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end

##############################
######  RECIPE METHODS  ######
##############################
def get_recipes
  sql = "SELECT name, id, instructions, description
  FROM recipes
  ORDER BY name"

  @recipes = db_connection do |db|
    db.exec_params(sql)
  end
  @recipes.to_a
end

def recipes_by_id(id)
  sql = "SELECT recipes.name, recipes.instructions, recipes.description, ingredients.name AS ing_list FROM recipes
  JOIN ingredients ON ingredients.recipe_id = recipes.id
  WHERE recipes.id = ($1)
  ORDER BY name"

  @recipe_id = db_connection do |db|
    db.exec_params(sql, [id])

  end
  @recipe_id.to_a
end


##############################
########## ROUTES ############
##############################

get '/' do

  erb :index
end

get '/recipes' do
  @all_recipe = get_recipes
  erb :'/recipes/index'
end

get '/recipes/:id' do
  @recipe_info = recipes_by_id(params["id"])
  erb :'/recipes/show'
end
