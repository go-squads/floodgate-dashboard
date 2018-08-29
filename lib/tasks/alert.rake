require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :alert do
  desc "Check all alert in database and send notification"
  task alert: :environment do
    print("\n\n\n")
    connect_to_db()
    alerts = @db["alerts"].find({})
    # print(alerts.to_json)
    alerts.each do  |obj|
      topic = obj["topic"]
      @collection = @db["#{topic}_logs"]
      obj["rules"].each do |r|
        range = r["range"].to_i
        time_bound = range.minute.ago.strftime("%Y-%m-%dT%H-%M-00Z")
        match_rule = match_rule(r["filter"], time_bound)
        group_rule =  {'_id': "count", 'count': {'$sum' => '$count'}}
        @data = @db["#{topic}_logs"].aggregate([{'$match'=> match_rule},{'$group' => group_rule}, {'$sort'=> {'_id': 1}}])
        if @data.first
          count = @data.first["count"]
          if check_threshold(r["threshold"],count, r["comparator"])
            puts("#{r["name"]} off the bound")
          else
            puts("#{r["name"]} still inside bound")
          end
        end
      end
    end
    print("\n\n\n")
  end
end
