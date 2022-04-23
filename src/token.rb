# frozen_string_literal: true

require 'aws-sdk-secretsmanager'

SECRET_ID = ENV['SECRET_ID']

# TokenStore
class TokenStore
  def initialize
    @client = Aws::SecretsManager::Client.new
  end

  def get
    resp = @client.get_secret_value(secret_id: SECRET_ID)
    resp.secret_string
  end

  def set(token:)
    @client.put_secret_value(
      secret_id: SECRET_ID,
      secret_string: token
    )
  end
end
