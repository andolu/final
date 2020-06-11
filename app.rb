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
users_table = DB.from(:users)

before do
    @current_user = users_table.where(:id => session[:user_id]).to_a[0]
    puts @current_user.inspect
end

get "/" do
    @rides = rides_table.all
    puts @rides.inspect
    view "rides"
end

get "/rides/:id" do
  
    @users_table = users_table
    @ride = rides_table.where(:id => params["id"]).to_a[0]
    results = Geocoder.search(@ride[:location])
    @lat_long = results.first.coordinates.join(",")
    @rsvps = rsvps_table.where(:ride_id => params["id"]).to_a
    @count = rsvps_table.where(:ride_id => params["id"], :going => true).count
    view "ride"
end

get "/rides/:id/rsvps/new" do
    @ride = rides_table.where(:id => params["id"]).to_a[0]
    puts @ride.inspect
    view "new_rsvp"
end    

get "/rides/:id/rsvps/create" do
    puts params.inspect
    rsvps_table.insert(:ride_id => params["id"],
                       :going => params["going"],
                       :user_id => @current_user[:id],
                       :comments => params["comments"])
       @ride = rides_table.where(:id => params["id"]).to_a[0]   
account_sid = ENV["TWILIO_ACCOUNT_SID"]
auth_token = ENV["TWILIO_AUTH_TOKEN"]
client = Twilio::REST::Client.new(account_sid, auth_token)
client.messages.create(
 from: "+14085479060", 
 to: "+16782006623",
 body: "Thank you for your response!"
)
       view "create_rsvp"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    users_table.insert(:name => params["name"],
                       :email => params["email"],
                       :password => BCrypt::Password.create(params["password"]))
    
account_sid = ENV["TWILIO_ACCOUNT_SID"]
auth_token = ENV["TWILIO_AUTH_TOKEN"]
client = Twilio::REST::Client.new(account_sid, auth_token)
client.messages.create(
 from: "+14085479060", 
 to: "+16782006623",
 body: "Thank you for signing Up!"
)
view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    puts params
    email_entered = params["email"]
    password_entered = params["password"]
    user = users_table.where(:email => email_entered).to_a[0]
    if user
        puts user.inspect
        if BCrypt::Password.new(user[:password]) == password_entered
            session[:user_id] = user[:id]
            view "create_login"
        else
            view "create_login_failed"
        end
    else 
        view "create_login_failed"
    end
end

get "/logout" do
    session[:user_id] = nil
    view "logout"
end