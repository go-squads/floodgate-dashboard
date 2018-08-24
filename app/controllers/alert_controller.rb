class AlertController < ApplicationController
  before_action :connect_to_db
  COLLECTION_ALERT = "alerts".freeze

  def index
    topic_name = "#{params['topic']}"
    @collection = @db[COLLECTION_ALERT]
    @res = @collection.find({topic: topic_name}).first
  end
  def store
    topic_name = "#{params['topic']}"
    @collection = @db[COLLECTION_ALERT]
    print('\n\n\n')
    obj = {
        'topic': topic_name,
        'mails': JSON.parse(params[:mailto_addresses]),
        'rules': JSON.parse(params[:rules]),
    }
    @res = @collection.update_one({topic: topic_name},obj, {upsert: true})

    print('\n\n\n')
    redirect_to "/#{topic_name}/alert"
  end
  def edit
    collection_name = "#{params['topic']}#{'_logs'}"

    @collection = @db[collection_name]
    @res = @db[COLLECTION_ALERT].find({topic: params['topic']}).first
  end
end
