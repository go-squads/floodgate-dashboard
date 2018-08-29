class DashboardController < ApplicationController
  require 'mongo'
  require 'matrix'
  require 'json'
  before_action :connect_to_db
  skip_before_action :verify_authenticity_token
  TIMESTAMP_PRECISION= {
      'minute' => '%Y-%m-%dT%H:%M:00Z',
      'hour' => '%Y-%m-%dT%H:00:00Z',
      'day' => '%Y-%m-%d',
      'month' => '%Y-%m-01',
      'year' => '%Y'
  }.freeze
  def index

  end

  def show
    collection_name = "#{params['topic']}#{'_logs'}"
    if @db.collection_names.include?(collection_name)
      @collection = @db[collection_name]
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def match_rule(filter, bound)
    puts("Building filter with: #{filter}")
    rule = {}
    filter.each do |k,v|
      if v.length > 0
        rule[k] = {'$in' => v}
      end
    end
    rule['timestamp'] = {'$gte' => bound}
    return rule
  end

  def fetch
    print("\n\n\n")
    collection_name = "#{params['topic']}#{'_logs'}"
    @collection = @db[collection_name]
    match_rule= match_rule(JSON.parse(params[:filter]), params[:bound])
    puts("Rule: #{match_rule.to_json}")
    time_format = TIMESTAMP_PRECISION[params['precision']]
    puts("Precision Format: #{params['precision']} => #{time_format}")
    group_rule =  {_id: {'$dateToString'=> {format: time_format, date: {'$dateFromString' => {dateString: '$timestamp'}}}}, count: {'$sum' => '$count'}}
    @data = @collection.aggregate([{'$match'=> match_rule},{'$group' => group_rule}, {'$sort'=> {'_id': 1}}])
  
    print("\n\n\n")
  end

  def linear_regress x, y
    x_data = x.map { |xi| (0..1).map { |pow| (xi**pow).to_r } }
    mx = Matrix[*x_data]
    my = Matrix.column_vector(y)
    return ((mx.t * mx).inv * mx.t * my).transpose.to_a[0].map(&:to_f)
  end
  
  def predict coefficients, x
    degree = 0
    result = 0
    for coefficient in coefficients
      result = result + coefficient*(x**degree)
      degree = degree +1
    end
    return result
  end

  def fetch_prediction 
    print("\n\n\n")
    data = params[:data]
    n = params[:n].to_i
    x = []
    for i in 0...data.length do
      x << i
      data[i] = data[i].to_i
    end
    model = linear_regress(x, data)
    @result = []
    for j in data.length...data.length+n do 
      @result << predict(model,j)
    end
    print("\n\n\n")
  end


end
