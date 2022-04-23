# frozen_string_literal: true

require 'date'
require_relative './lib/token'
require_relative './lib/aka4'
require_relative './lib/notification'

$store = TokenStore.new
$aka4 = Aka4Client.new
$notification = Notification.new

# LambdaFunction
module LambdaFunction
  # Handler
  class Handler
    def self.refresh(event:, context:)
      token = $store.get
      new_token = $aka4.reissue_token(token: token)
      $store.set(token: new_token)
      $notification.notify(message: 'アクセストークンが正常にローテーションされました')
    rescue StandardError => e
      $notification.notify(message: e.message)
    end

    def self.punch(event:, context:)
      token = $store.get
      type, stamped_at = $aka4.punch(token: token)
      $notification.notify(message: "#{stamped_at}に#{type}しました")
    rescue StandardError => e
      $notification.notify(message: e.message)
    end
  end
end
