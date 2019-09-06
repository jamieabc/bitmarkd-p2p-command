# frozen_string_literal: true

require 'pry'
require 'colorize'

module Command
  # info - get bitmarkd info
  class Base
    def info
      send_chain
      send_final_message(info_prefix)
      msgs = receive_message
      parse_info(client.name, msgs[1])
    end

    private

    def parse_info(name, resp)
      hsh = JSON.parse(resp).to_h
      version = hsh['version'].ljust(version_length)
      chain = hsh['chain'].ljust(chain_length)
      normal = hsh['normal'] ? 'N'.colorize(:blue) : 'R'.colorize(:red)
      "#{name.ljust(name_length)} #{version} #{chain} #{normal}"
    end

    def info_prefix
      'I'
    end

    def version_length
      15
    end

    def chain_length
      8
    end

    def name_length
      8
    end
  end
end
