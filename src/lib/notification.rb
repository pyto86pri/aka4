# frozen_string_literal: true

require 'aws-sdk-sns'

TOPIC_ARN = ENV['TOPIC_ARN']

# Notification
class Notification
  def initialize
    @client = Aws::SNS::Client.new
  end

  def notify(message:)
    @client.publish(topic_arn: TOPIC_ARN, subject: 'Akashi', message: message)
  end
end
