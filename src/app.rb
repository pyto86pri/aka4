# frozen_string_literal: true

require 'date'
require_relative './lib/token'
require_relative './lib/aka4'

$store = TokenStore.new
$aka4 = Aka4Client.new

# LambdaFunction
module LambdaFunction
  # Handler
  class Handler
    def self.refresh(event:, context:)
      token = $store.get
      new_token = $aka4.reissue_token(token: token)
      $store.set(token: new_token)
    end

    def self.punch(event:, context:)
      token = $store.get
      $aka4.punch(token: token)
    end
  end
end
