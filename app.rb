# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

rides_table = DB.from(:rides)
rsvps_table = DB.from(:rsvps)

get "/" do
    @rides = rides_table.all
    puts @rides.inspect
    view "rides"
end

get "/rides/:id" do
    @ride = rides_table.where(:id => params["id"]).to_a[0]
    puts @ride.inspect
    view "ride"
end

get "/rides/:id/rsvps/new" do
    @ride = rides_table.where(:id => params["id"]).to_a[0]
    puts @ride.inspect
    view "new_rsvp"
end    