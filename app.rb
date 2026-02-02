require 'sinatra'
require 'sinatra/activerecord'
require 'rake'
require 'httparty'
require 'dotenv/load'
require './models/movie.rb'

get '/' do 
  erb :index
end

get '/search' do
  query = params[:q]
  return redirect '/' if query.nil? || query.strip.empty?

  api_key = ENV['API_KEY']
  url = "http://www.omdbapi.com/?s=#{query}&apikey=#{api_key}"

  response = HTTParty.get(url)
  result = JSON.parse(response.body)

  if result["Response"] == "True"
    @movies = result["Search"]
    erb :search
  else
    @error = "Filme não encontrado."
  end
end

post '/favorites' do 
  unless Movie.exists?(imdb_id: params[:imdb_id])
      Movie.create(
        title: params[:title],
        year: params[:year],
        poster: params[:poster],
        imdb_id: params[:imdb_id]
      )
  end
  redirect '/favorites'
end

get '/favorites' do
  @favorites = Movie.all
  erb :favorites
end
delete '/favorites/:id' do
 
  movie = Movie.find(params[:id])
  
  
  movie.destroy
  
    redirect '/favorites'
end