# frozen_string_literal: true

require 'pry'
require 'yaml'
Dir[File.join(__dir__, 'command', '*.rb')].each { |file| require file }

# use input config if exist
default_config_file = 'config.yml'
config_file = ARGV.empty? ? default_config_file : ARGV[0]

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
    block_hash = c.block_hash(height)
    header = c.block_header(height)
    puts "#{info_str} #{height} #{block_hash} #{header[:time] if header}"
  end
  c.close
end