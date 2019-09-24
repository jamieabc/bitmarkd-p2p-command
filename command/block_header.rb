# frozen_string_literal: true

require 'colorize'

module Command
  # block_hash - get block hash for specific block number
  class Base
    def block_header(block_number)
      send_chain
      send_message_and_more(block_header_prefix)
      send_final_message([block_number.to_i].pack('J>'))
      msgs = receive_message
      parse_header(msgs[1])
    end

    def parse_header(resp)
      unpacked = resp.unpack('H*').first
      {
        version: extract_version(unpacked),
        count: extract_transaction_count(unpacked),
        number: extract_block_number(unpacked),
        prev_block: extract_prev_block(unpacked),
        merkle: extract_merkle_root(unpacked),
        time: extract_timestamp(unpacked),
        difficulty: extract_difficulty(unpacked),
        nonce: extract_nonce(unpacked)
      }
      # puts "version: #{extract_version(unpacked)}"
      # puts "transaction count: #{extract_transaction_count(unpacked)}"
      # puts "number: #{extract_block_number(unpacked)}"
      # puts "prev block: #{extract_prev_block(unpacked)}"
      # puts "merkle: #{extract_merkle_root(unpacked)}"
      # puts "time: #{extract_timestamp(unpacked)}"
      # puts "difficulty: #{extract_difficulty(unpacked)}"
      # puts "nonce: #{extract_nonce(unpacked)}"
    end

    def extract_version(unpacked)
      unpacked[0..3].scan(/../).reverse.join.to_i
    end

    def extract_transaction_count(unpacked)
      unpacked[4..7].scan(/../).reverse.join.to_i
    end

    def extract_block_number(unpacked)
      unpacked[8..23].scan(/../).reverse.join.to_i(16)
    end

    def extract_prev_block(unpacked)
      unpacked[24..87].scan(/../).reverse.join
    end

    def extract_merkle_root(unpacked)
      unpacked[88..151].scan(/../).reverse.join
    end

    def extract_timestamp(unpacked)
      Time.at(unpacked[152..167].scan(/../).reverse.join.to_i(16))
    end

    def extract_difficulty(unpacked)
      unpacked[168..183].scan(/../).reverse.join
    end

    def extract_nonce(unpacked)
      unpacked[184..199].scan(/../).reverse.join.to_i(16)
    end

    def block_header_prefix
      'B'
    end

    def version(bytes)
      bytes
    end
  end
end
