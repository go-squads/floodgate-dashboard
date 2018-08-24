class AlertController < ApplicationController
  before_action :connect_to_db

  def index

  end
  def edit
    collection_name = "#{params['topic']}#{'_logs'}"
    @collection = @db[collection_name]
  end
end
