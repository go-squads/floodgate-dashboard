class AlertMailer < ApplicationMailer
  def alert(mailto, alert_name, topic)
    puts("Sending mail from #{ENV["MAIL_ADDRESS"]}")
    @alert_name = alert_name
    @topic = topic
    mail(to: mailto, subject: "Alert for #{alert_name} in #{topic}")
  end
end
