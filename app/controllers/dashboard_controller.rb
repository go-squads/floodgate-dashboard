class DashboardController < ApplicationController
  require 'mongo'
  before_action :connect_to_db
  skip_before_action :verify_authenticity_token

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

  def fetch
    collection_name = "#{params['topic']}#{'_logs'}"
    @collection = @db[collection_name]
    filter = JSON.parse(params[:filter])
    print("Hello World!", filter)
    @data = @collection.aggregate([{'$group' => {_id: '$timestamp', count: {'$sum' => '$count'}}}])
  end
end
