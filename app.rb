require 'sinatra'
require 'sinatra/activerecord'
require 'rake'
require 'httparty'
require 'dotenv/load'
require './models/movie.rb'
set :method_override, true

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
    erb :search
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
  @favorites = Movie.order(created_at: :desc)
  
  movie = Movie.find(params[:id])
  
  
  movie.destroy
  
    redirect '/favorites'
end

# ROTA DE DETALHES
get '/details/:imdb_id' do
  imdb_id = params[:imdb_id]
  api_key = ENV['API_KEY']
  # 1. Busca os detalhes completos na API (Note o parâmetro 'i=' e 'plot=full')
  url = "http://www.omdbapi.com/?i=#{imdb_id}&plot=full&apikey=#{api_key}"
  response = HTTParty.get(url)
  @movie = JSON.parse(response.body)

  # 2. Verifica se esse filme JÁ existe no seu banco de dados
  # Isso serve para decidirmos se mostramos o botão "Salvar" ou "Remover"
  @local_movie = Movie.find_by(imdb_id: imdb_id)

  erb :details
end