# frozen_string_literal: true

require 'pry'
require 'yaml'
Dir[File.join(__dir__, 'command', '*.rb')].each { |file| require file }

config_file = 'config.yml'

yml_config = YAML.load_file(config_file)

ZmqSocket.set_keys(yml_config['public_key'], yml_config['private_key'])

clients = []

yml_config['nodes'].each do |n|
  clients << Command::Base.new(n)
end

clients.each do |c|
  info_str, mode = c.info
  if mode == 'normal'
    height = c.height
    block_hash = c.block_hash(height) if mode == 'normal'
  end
  puts "#{info_str} #{height} #{block_hash}"
  c.close
end