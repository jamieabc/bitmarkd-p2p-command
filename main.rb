# frozen_string_literal: true

require "ffi-rzmq"
require "json"
require "yaml"
require_relative 'socket'

config_file = "config.yml"

yml_config = YAML.load_file(config_file)

Socket.set_keys(yml_config["public_key"], yml_config["private_key"])

sockets = []

puts "create zmq sockets"
yml_config["nodes"].each do |n|
  sockets << Socket.new(n)
end

def parse_response(name, resp)
  hsh = JSON.parse(resp).to_h
  puts "#{name} response: #{hsh}"
end

puts "query bitmarkd info"
sockets.each do |s|
  s.send("testing", ZMQ::SNDMORE)
  s.send("I", 0)
  msgs = s.receive
  parse_response(s.name, msgs[1])
end

sockets.each(&:close)
