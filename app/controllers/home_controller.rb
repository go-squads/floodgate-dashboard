require 'influxdb'
class HomeController < ApplicationController
    
  def index
    @topics = get_topics
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
    puts "fieldset: "+@fieldset.to_s
    respond_to do |format|
      format.js
    end
  end

  def visualize
    dbclient = connect_to_influx
    column_names = params[:field].split(",")
    string_select_builder = ''
    column_names.each do |each|
      string_select_builder = string_select_builder +','+ 'sum("'+each+'") AS "'+ each + '"' 
    end
    interval = ""
    case params[:timerange]
    when "1d"
      interval = "2h"
    when "1w"
      interval = "1d"
    when "1m"
      interval = "2d"
    when "1y"
      interval = "1m"
    else
      interval = "1h"
    end
    cmd = 'SELECT '+string_select_builder[1...string_select_builder.length]+' FROM "analyticsKafkaDB"."autogen"."'+params[:measurement]+'" where time > now() - '+params[:timerange]+' group by time('+interval+') FILL(0)'
    puts "command: "+cmd
    @response = dbclient.query(cmd)
    data_to_visualize = map_timeseries(@response)
    puts "RESPONSE: "+@response[0]["values"].to_s

      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: params[:measurement])
        f.xAxis(categories: data_to_visualize["time"])
        column_names.each {
          |column_name|
          f.series(name: column_name, yAxis: 0, data: data_to_visualize[column_name])
        # f.series(name: column_names[1], yAxis: 0, data: data_to_visualize[column_names[1]])
        }
      
        f.yAxis [
          {title: {text: "count", margin: 70} },
        ]
      
        f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical')
        f.chart({defaultSeriesType: "column", type: "areaspline"})
      end
      
      @chart_globals = LazyHighCharts::HighChartGlobals.new do |f|
        f.global(useUTC: false)
        f.chart(
          backgroundColor: {
            linearGradient: [0, 0, 500, 500],
            stops: [
              [0, "rgb(255, 255, 255)"],
              [1, "rgb(240, 240, 255)"]
            ]
          },
          borderWidth: 2,
          plotBackgroundColor: "rgba(255, 255, 255, .9)",
          plotShadow: true,
          plotBorderWidth: 1
        )
        f.lang(thousandsSep: ",")
        f.colors(["#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354"])
      end
      respond_to do |format|
        format.js
      end
    end

  def map_timeseries(query_response)
    if query_response.length != 0 
      keyed_data = Hash.new()
      query_response[0]["values"].each do |data|
        data.each do |key, value|
          puts "Data to Put: " + key + " " + value.to_s
          if (!keyed_data[key]) 
            keyed_data[key] = Array.new
          end
             
          if (key == "time")
            value = DateTime.strptime(value).new_offset(DateTime.now.offset)
          end
        
          keyed_data[key].push(value)
        end
        puts "datatovis:" + keyed_data.to_s
      end
    end   

    return keyed_data
  end
end

