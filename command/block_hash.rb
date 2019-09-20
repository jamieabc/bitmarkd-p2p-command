# frozen_string_literal: true

require 'colorize'

module Command
  # block_hash - get block hash for specific block number
  class Base
    def block_hash(block_number)
      send_chain
      send_message_and_more(block_hash_prefix)
      send_final_message([block_number.to_i].pack('J>'))
      msgs = receive_message
      parse_hash(msgs[1]) if msgs.length == 2
    end

    def parse_hash(resp)
      resp.unpack('H*').first.ljust(hash_length)[0..hash_str_length]
    end

    def block_hash_prefix
      'H'
    end

    def hash_str_length
      10
    end

    def hash_length
      6
    end
  end
end
