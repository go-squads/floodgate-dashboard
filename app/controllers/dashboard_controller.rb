class DashboardController < ApplicationController
  require 'mongo'
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
end
