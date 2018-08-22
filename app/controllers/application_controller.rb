class ApplicationController < ActionController::Base
  def connect_to_db
   if !@db
     db_address = ENV["MONGO_ADDRESS"]
     print("Connecting to MongoDB with: #{db_address}" )
     client = Mongo::Client.new(db_address)
     @db = client.use(ENV["MONGO_NAME"]).database
   end
  end
end
