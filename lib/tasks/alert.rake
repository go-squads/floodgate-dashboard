require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :alert do
  desc "Check all alert in database and send notification"
  task alert: :environment do
    print("\n\n\n")
    check_alert()
    print("\n\n\n")
  end
end
