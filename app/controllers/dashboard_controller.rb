class DashboardController < ApplicationController
  require 'mongo'
  before_action :connect_to_db
  def index

  end
end
