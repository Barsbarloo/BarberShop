require 'rubygems'
require 'sinatra'
#require "sinatra/reloader"
require 'sqlite3'

configure do
  @db = SQLite3::Database.new 'barbershop.db'
  @db.execute 'CREATE TABLE IF NOT EXISTS 
  "Users" 
  (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT, 
    "username" TEXT, 
    "phone" INTEGER, 
    "datestamp" INTEGER, 
    "barber" TEXT
    )'  
end

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
get '/about' do
    erb :about
end
get '/visit' do
  erb :visit
end
post '/visit' do
  # user_name, phone, date_time
  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @baber = params[:baber]
  #hash
  hh = { :username => 'Enter your name',
         :phone => 'Enter your phone number',
         :datetime => 'Enter date and time'
  }
    hh.each do |key, value|
      # If parameters are empty
      if params[key]==''
        #переменной error присвоить value из хеша
        #а value из хеша это сообщение об ошибке
        #т.е. переменной error присвоит сообшение об ошибке
        @error = hh[key]
        #вернуть представление visit
        return erb :visit
      end
    end

  @title = "Thank you!"
  @message = "Уважаемый #{@username}, мы ждём вас #{@datetime} у выбранного парикмахера #{@baber}."

  # запишем в файл то, что ввёл клиент
  f = File.open './public/users.txt', 'a'
  f.write "User: #{@username}, phone: #{@phone}, date and time: #{@datetime}. Barber: #{@baber}.\n"
  f.close

  erb :message
end
