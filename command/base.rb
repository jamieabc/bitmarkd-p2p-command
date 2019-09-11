# frozen_string_literal: true

require 'json'
require_relative '../zmq_socket'
require_relative '../rpc_socket'

module Command
  # Base - base class for command
  class Base
    attr_accessor :zmq, :chain, :rpc, :name

    def initialize(hsh = {})
      raise 'invalid chain' if hsh.fetch('chain').empty?
      raise 'invalid ip' if hsh.fetch('ip4').empty?
      raise 'invalid port' if hsh.fetch('zmq_port').zero?
      raise 'invalid name' if hsh.fetch('name').empty?

      @chain = hsh.fetch('chain')
      @name = hsh.fetch('name')
      @zmq = ZmqSocket.new(hsh)
      @rpc = RPCSocket.new(hsh)
    end

    def close
      zmq.close
      rpc.close
    end

    private

    def send_chain
      zmq.send_chain(chain)
    end

    def send_final_message(arg)
      zmq.send(arg, 0)
    end

    def send_message_and_more(arg)
      zmq.send(arg, ZMQ::SNDMORE)
    end

    def receive_message
      zmq.receive
    end
  end
end