require 'influxdb'
class HomeController < ApplicationController
    
  def index
    @topics = get_topics
  end

  def connect_to_influx
    databaseClient = InfluxDB::Client.new(
      host: ENV["INFLUXDB_HOST"],
      port: ENV["INFLUXDB_PORT"],
      database: ENV["INFLUXDB_NAME"],
      username: ENV["INFLUXDB_USER"],
      password: ENV["INFLUXDB_PASS"],
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
    respond_to do |format|
      format.js
    end
  end

  def visualize
    traffic_exist = false
    dbclient = connect_to_influx
    column_names = params[:field].split(",")
    string_select_builder = ''
    column_names.each do |each|
      if each == "INFO"
        traffic_exist = true
      end
      #query string
      string_select_builder = string_select_builder +','+ 'sum("'+each+'") AS "'+ each + '"' 
    end
    interval = interval_based_on_timerange(params[:timerange])
    #build the full query string
    cmd = 'SELECT '+string_select_builder[1...string_select_builder.length]+' FROM "analyticsKafkaDB"."autogen"."'+params[:measurement]+'" where time > now() - '+params[:timerange]+' group by time('+interval+') FILL(0)'
    #query influxdb
    @response = dbclient.query(cmd)
    puts "this is the response"
    puts @response
    # TODO: DO THE SAME FOR WARNING
    if traffic_exist 
        create_map_error_threshold(@response)
        puts "this is after the change"
        puts @response
        column_names.push("error_limit")
    end
    data_to_visualize = map_timeseries(@response)
    # IDEA ATTACH THE VALUES ARR INTO THE VALUES ARRAY
    # Response example
    # {"name"=>"go-testerror_logs_Errors", "tags"=>nil, 
    #     "values"=>[{"time"=>"2018-08-08T20:00:00Z", "200_NO_POST"=>0}, 
    #         {"time"=>"2018-08-08T21:00:00Z", "200_NO_POST"=>0}, 
    #         {"time"=>"2018-08-08T22:00:00Z", "200_NO_POST"=>0}, 
    # I want time but i want to calculate the values -> Remap the values
    if data_to_visualize != nil
      draw_chart(data_to_visualize, column_names)
    end
    respond_to do |format|
      format.js
    end
  end

  def create_map_error_threshold(info_query_response)
    error_percentage = 0
    result_values_hash_array = Array.new()
    info_query_response[0]["values"].each do |data|
        time_val_hash = Hash.new()
        data.each do |label, info_value|
            puts "the label"
            puts label
            if label == "INFO"
                puts info_value
                error_percentage = (info_value / 100.0) * 10
                puts error_percentage
            end
        end
        data.store("error_limit", error_percentage)
    end

    return
  end


  def map_timeseries(query_response)
    if query_response.length != 0 
      keyed_data = Hash.new()
      query_response[0]["values"].each do |data|
        data.each do |key, value|
          if (!keyed_data[key]) 
            keyed_data[key] = Array.new
          end
          if (key == "time")
            value = DateTime.strptime(value).new_offset(DateTime.now.offset)
          end
        
          keyed_data[key].push(value)
        end
      end
    end   

    return keyed_data
  end

  def interval_based_on_timerange(timerange)
    interval=""
    case timerange
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
    interval
  end

  def draw_chart(data_to_visualize, column_names)
    puts "data_to_vis"
    puts data_to_visualize
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: params[:measurement])
      f.xAxis(categories: data_to_visualize["time"])
      column_names.each do |column_name|
        puts "Column name below:"
        puts column_name
        f.series(name: column_name, yAxis: 0, data: data_to_visualize[column_name])
      end
    
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
  end
end

