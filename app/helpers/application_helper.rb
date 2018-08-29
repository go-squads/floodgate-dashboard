module ApplicationHelper
  TIMESTAMP_PRECISION= {
      'minute' => '%Y-%m-%dT%H:%M:00Z',
      'hour' => '%Y-%m-%dT%H:00:00Z',
      'day' => '%Y-%m-%d',
      'month' => '%Y-%m-01',
      'year' => '%Y'
  }.freeze


  def connect_to_db
    if !@db
      db_address = ENV["MONGO_ADDRESS"]
      print("Connecting to MongoDB with: #{db_address}" )
      client = Mongo::Client.new(db_address)
      @db = client.use(ENV["MONGO_NAME"]).database
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
  def check_threshold(threshold, count, comparator)
    threshold = threshold.to_i
    count = count.to_i
    case comparator
      when 'lte'
        return (count <= threshold)
      when 'gte'
        return (count >= threshold)
      when 'gt'
        return (count > threshold)
      when 'lt'
        return (count < threshold)
      end
  end
  def send_alert(mailto, alert_name, topic)
    puts("Sending Alert to #{mailto} for #{alert_name} in topic #{topic}")
    AlertMailer.alert(mailto, alert_name, topic).deliver_now()
  end

  def check_alert()
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
            obj["mails"].each do |mail|
              send_alert(mail, r["name"], topic)
            end
          else
            puts("#{r["name"]} still inside bound")
          end
        end
      end
    end
  end
end
