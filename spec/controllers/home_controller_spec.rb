require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "#connect_to_influx" do
    it "can connect successfully" do
      test = HomeController.new
      expect(test.connect_to_influx()).not_to eq(nil)
    end
  end

  describe "#get_topics" do
    it "can get topic lists properly" do
        test = HomeController.new
        expect(test.get_topics().length).not_to eq(0)
    end
  end


end
