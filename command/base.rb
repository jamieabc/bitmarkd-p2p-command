# frozen_string_literal: true

require 'json'
require_relative '../zmq_socket'

module Command
  # Base - base class for command
  class Base
    attr_accessor :client, :chain

    def initialize(hsh = {})
      raise 'invalid chain' if hsh.fetch('chain').empty?
      raise 'invalid ip' if hsh.fetch('ip4').empty?
      raise 'invalid port' if hsh.fetch('zmq_port').zero?

      @chain = hsh.fetch('chain')
      @client = ZmqSocket.new(hsh)
    end

    def close
      client.close
    end

    private

    def send_chain
      client.send_chain(chain)
    end

    def send_final_message(arg)
      client.send(arg, 0)
    end

    def send_message_and_more(arg)
      client.send(arg, ZMQ::SNDMORE)
    end

    def receive_message
      client.receive
    end
  end
end