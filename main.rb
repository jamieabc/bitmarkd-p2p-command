# frozen_string_literal: true

require 'yaml'
Dir[File.join(__dir__, 'command', '*.rb')].each { |file| require file }

config_file = 'config.yml'

yml_config = YAML.load_file(config_file)

ZmqSocket.set_keys(yml_config['public_key'], yml_config['private_key'])

clients = []

yml_config['nodes'].each do |n|
  clients << Command::Base.new(n)
end

def parse_response(name, resp)
  hsh = JSON.parse(resp).to_h
  puts "#{name} response: #{hsh}"
end

clients.each do |c|
  info = c.info
  height = c.height
  block_hash = c.block_hash(height)
  puts "#{info} #{height} #{block_hash}"
  c.close
end
