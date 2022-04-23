# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

BASE_URL = 'https://atnd.ak4.jp/api/cooperation'
CORPORATION_ID = ENV['CORPORATION_ID']

TYPE_MAP = { 11 => '出勤', 12 => '退勤' }.freeze

# Aka4
class Aka4Client
  def reissue_token(token:)
    resp = post_to_aka4("/token/reissue/#{CORPORATION_ID}", { token: token })
    resp['token']
  end

  def punch(token:)
    resp = post_to_aka4("/#{CORPORATION_ID}/stamps", { token: token })
    [TYPE_MAP[resp['type']], resp['stampedAt']]
  end
end

def post_to_aka4(path, data)
  resp = post_json("#{BASE_URL}#{path}", data)
  raise StandardError, resp.body unless resp.code.to_i == 200

  json = JSON.parse(resp.body)
  unless json['success']
    raise StandardError, json['errors'].map do |error|
      "#{error.code}: #{error.message}"
    end.join("\n")
  end

  json['response']
end

def post_json(url, data)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type': 'application/json' })
  req.body = data.to_json
  http.request(req)
end
