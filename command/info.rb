require "pry"

module Command
  # Info - get bitmarkd info
  class Base
    def info
      send_chain
      send_message(info_prefix)
      msgs = receive_message
      parse_message(client.name, msgs[1])
    end

    private

    def parse_message(name, resp)
      hsh = JSON.parse(resp).to_h
      puts "#{name} response: #{hsh}"
    end

    def info_prefix
      "I"
    end
  end
end