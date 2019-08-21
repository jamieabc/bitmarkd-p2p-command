# frozen_string_literal: true

require "ffi-rzmq"
require "json"
require "yaml"
Dir[File.join(__dir__, 'command', '*.rb')].each { |file| require file }

config_file = "config.yml"

yml_config = YAML.load_file(config_file)

ZmqSocket.set_keys(yml_config["public_key"], yml_config["private_key"])

clients = []

puts "create zmq clients"
yml_config["nodes"].each do |n|
  clients << Command::Base.new(n)
end

def parse_response(name, resp)
  hsh = JSON.parse(resp).to_h
  puts "#{name} response: #{hsh}"
end

puts "query bitmarkd info"
clients.each do |c|
  c.info
  c.close
end
