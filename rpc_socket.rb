# frozen_string_literal: true

require 'socket'
require 'openssl'

# class for tls rpc socket
class RPCSocket
  attr_reader :rpc

  def initialize(hsh)
    host = hsh.fetch('ip4')
    port = hsh.fetch('ssl_port')

    tpc_socket = TCPSocket.new(host, port)
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.set_params(verify_mode: OpenSSL::SSL::VERIFY_NONE)
    @rpc = OpenSSL::SSL::SSLSocket.new(tpc_socket, ctx)
    rpc.sync_close = true
    rpc.connect
  end

  def info
    params = JSON.dump(
      method: 'Node.Info',
      params: [{}],
      id: rand(1..1000).to_s
    )

    rpc.write(params)
    JSON.parse(rpc.gets)
  end

  def close
    rpc.close
  end
end
