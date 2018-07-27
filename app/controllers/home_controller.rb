require 'influxdb'
class HomeController < ApplicationController
    
  def index
    @topics = get_topics
    puts @topics.to_s
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
    topic_list = topic_list_query[0]
  end

  def get_fieldset
    dbclient = connect_to_influx
    measurement = params[:measurement]
    response = dbclient.query('SHOW FIELD KEYS FROM "'+ measurement+'"')
    @fieldset = response[0]
  end
  
end
