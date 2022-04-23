# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

BASE_URL = 'https://atnd.ak4.jp/api/cooperation'
CORPORATION_ID = ENV['CORPORATION_ID']

START_WORK = 11
FINISH_WORK = 12

# Aka4
class Aka4Client
  def reissue_token(token:)
    uri = URI.parse("#{BASE_URL}/token/reissue/#{CORPORATION_ID}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type': 'application/json' })
    req.body = { token: token }.to_json
    resp = http.request(req)
    json = JSON.parse(resp.body)
    json['response']['token'] if json['success']
  end

  def punch(token:)
    uri = URI.parse("#{BASE_URL}/#{CORPORATION_ID}/stamps")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type': 'application/json' })
    req.body = { token: token }.to_json
    resp = http.request(req)
    json = JSON.parse(resp.body)
    json['success']
  end
end
