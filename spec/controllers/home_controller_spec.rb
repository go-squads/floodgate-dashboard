require 'rails_helper'
require 'date'

RSpec.describe HomeController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(200)
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
        # controller.params = ActionController::Parameters.new({ measurement: "go-wednesday_logs" })
        # expect(controller.send(:get_fieldset)).not_to eq(nil)

        get :get_fieldset, params: { measurement: "go-wednesday_logs" }, xhr: true
        expect(response).to have_http_status(200)
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
        testMeasureHash["time"] = DateTime.current.to_s
        testValueArr.push(testMeasureHash)
        testMap["values"] = testValueArr
        testResponse.push(testMap)
        expect(test.map_timeseries(testResponse)).not_to eq(nil)
    end
  end

  describe "#interval_based_on_timerange" do
    test = HomeController.new
    it "returns 2h interval when the timerange is 1d" do
      expect(test.interval_based_on_timerange("1d")).to eq("2h")
    end
    it "returns 1d interval when the timerange is 1w" do
      expect(test.interval_based_on_timerange("1w")).to eq("1d")
    end
    it "returns 2d interval when the timerange is 1m" do
      expect(test.interval_based_on_timerange("1m")).to eq("2d")
    end
    it "returns 1m interval when the timerange is 1y" do
      expect(test.interval_based_on_timerange("1y")).to eq("1m")
    end
    it "returns 1h interval when the timerange is not listed" do
      expect(test.interval_based_on_timerange("12h")).to eq("1h")
    end
  end
end
