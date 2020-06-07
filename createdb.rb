# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :rides do
  primary_key :id
  String :title
  String :description, text: true
  String :date
  String :location
end
DB.create_table! :rsvps do
  primary_key :id
  foreign_key :ride_id
  Boolean :going
  String :name
  String :email
  String :comments, text: true
end

# Insert initial (seed) data
rides_table = DB.from(:rides)

rides_table.insert(title: "Fabulous Farmer's Market", 
                    description: "We are excited to take our amazing senior community members on a visit to the local farmer's market.!",
                    date: "June 13",
                    location: "Paulus Park")

rides_table.insert(title: "Local Library Visit", 
                    description: "If books are your best friends, you will love a trip to the library.",
                    date: "June 14",
                    location: "Ela Library")
