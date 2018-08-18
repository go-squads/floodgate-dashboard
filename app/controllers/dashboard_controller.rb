class DashboardController < ApplicationController
  require 'mongo'
  before_action :connect_to_db
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
end
