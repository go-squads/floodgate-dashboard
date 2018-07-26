require "influxdb"

class HomeController < ApplicationController
    
  def index
    # dbclient = connect_to_influx
    # databaseClient = InfluxDB::Client.new (
    #     database: "analyticsKafkaDB",
    #     username: "",
    #     password: "",
    #     retry: 4
    # )
    # end
    # response = databaseClient.query("SHOW MEASUREMENTS")
    # puts response.to_s
  end

  def connect_to_influx
    databaseClient = InfluxDB::Client.new(
        database: Rails.application.config.database_name,
        username: Rails.application.config.user_name,
        password: Rails.application.config.password,
        retry: 4
    )
  end

  def get_topics
    dbclient = connect_to_influx()
    topic_list_query = dbclient.query('show measurements')
    @topic_list = topic_list_query[0]
  end

  

  
end
