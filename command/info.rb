# frozen_string_literal: true

require 'pry'
require 'colorize'

module Command
  # info - get bitmarkd info
  class Base
    def info
      send_chain
      send_message(info_prefix)
      msgs = receive_message
      parse_info(client.name, msgs[1])
    end

    private

    def parse_info(name, resp)
      hsh = JSON.parse(resp).to_h
      version = hsh['version'].ljust(10)
      chain = hsh['chain'].ljust(8).colorize(:green)
      normal = hsh['normal'] ? 'N'.colorize(:blue) : 'R'.colorize(:blue)
      "#{name.ljust(8)} #{version} #{chain} #{normal}"
    end

    def info_prefix
      'I'
    end
  end
end
