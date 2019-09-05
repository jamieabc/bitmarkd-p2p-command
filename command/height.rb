require 'colorize'

module Command
  # height - get block height
  class Base
    def height
      send_chain
      send_message(height_prefix)
      msgs = receive_message
      parse_height(msgs[1])
    end

    def parse_height(resp)
      resp.unpack('H*').first.to_i(16).to_s.ljust(6)
    end

    def height_prefix
      'N'
    end
  end
end