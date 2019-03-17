require 'sinatra'
require 'sinatra/flash'
require_relative 'rewarding'
enable :sessions

rewarding = Rewarding.new

get '/' do
  @users = rewarding.rating
  erb :app
end

post '/' do
  begin
    @filename = params[:file][:filename]
    file = params[:file][:tempfile]
    rewarding.push(file.read)
  rescue Rewarding::TimeCollisionError
    flash[:alert] = "Provided data predates one or more
                     records from the past. Make sure your
                     new records are after #{rewarding.safe_time}"
  rescue Rewarding::ParsingError
    flash[:alert] = 'One or more lines in your file are of improper format'
  rescue Rewarding::TimeFormatError
    flash[:alert] = 'One or more lines in your file
                     contain date of improper format'
  end
  redirect '/'
end

delete '/' do
  rewarding.flush
  redirect '/'
end
