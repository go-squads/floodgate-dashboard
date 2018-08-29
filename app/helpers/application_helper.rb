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
end
