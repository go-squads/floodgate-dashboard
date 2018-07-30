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

  describe "#get_fieldset" do
    it "can get field lists properly" do
        test = HomeController.new
        controller.params = ActionController::Parameters.new({ measurement: "go-wednesday_logs" })
        expect(controller.send(:get_fieldset)).not_to eq(nil)
    end
  end

  describe "#map_timeseries" do
    it "will return nil if the response is nil" do
        test = HomeController.new
        testArr = Array.new
        expect(test.map_timeseries(testArr)).to eq(nil)
    end

    it "will return a properly mapped list" do
        test = HomeController.new
        testResponse = Array.new
        testMap = Hash.new
        testValueArr = Array.new
        testMeasureHash = Hash.new
        testMeasureArr = Array.new
        testMeasureArr.push(10)
        testMeasureHash["test"] = testMeasureArr
        testValueArr.push(testMeasureHash)
        testMap["values"] = testValueArr
        testResponse.push(testMap)
        expect(test.map_timeseries(testResponse)).not_to eq(nil)
    end
  end


end
