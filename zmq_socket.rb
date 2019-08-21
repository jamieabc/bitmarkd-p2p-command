# frozen_string_literal: true

# ZmqSocket is for abstraction of zeromq socket
class ZmqSocket
  attr_reader :client_public_key, :ip, :port, :socket, :name, :chain

  @@client_public_key = ""
  @@client_private_key = ""

  def initialize(hsh = {})
    set_connection(hsh.fetch("ip4"), hsh.fetch("port"))
    @client_public_key = hsh.fetch("public_key")
    @socket = create_zmq_socket
    socket_option
    socket.connect(connection)
    @name = hsh.fetch("name")
    @chain = hsh.fetch("chain")
  end

  def connection
    "tcp://#{ip}:#{port}"
  end

  def send_chain
    check_client_keys
    socket.send_string(chain, ZMQ::SNDMORE)
  end

  def send(str, zmq_flag)
    check_client_keys
    socket.send_string(str, zmq_flag)
  end

  def receive
    check_client_keys
    messages = []
    socket.recv_strings(messages)
    messages
  end

  def close
    socket.close
  end

  def self.set_keys(public, private)
    @@client_public_key = public
    @@client_private_key = private
  end

  private

  def check_client_keys
    raise "Error no client key" if @@client_private_key.empty? || @@client_public_key.empty?
  end

  def create_zmq_socket
    ctx = ZMQ::Context.new
    ctx.socket(ZMQ::REQ)
  end

  def set_connection(ip, port)
    @ip = ip
    @port = port
  end

  def random_identity
    (0..31).map { rand(69..91).chr }.join
  end

  def socket_option
    set_socket_encryption
    socket.setsockopt(ZMQ::IMMEDIATE, 1)
    socket.setsockopt(ZMQ::IDENTITY, random_identity)
    socket.setsockopt(ZMQ::REQ_CORRELATE, 1)
    socket.setsockopt(ZMQ::REQ_RELAXED, 1)
    socket_tcp_keepalive
    socket.setsockopt(ZMQ::MAXMSGSIZE, 5_000_000)
  end

  def set_socket_encryption
    socket.setsockopt(ZMQ::CURVE_SERVER, 0)
    socket.setsockopt(ZMQ::CURVE_SERVERKEY, [client_public_key].pack("H*").to_s)
    socket.setsockopt(ZMQ::CURVE_PUBLICKEY, [@@client_public_key].pack("H*").to_s)
    socket.setsockopt(ZMQ::CURVE_SECRETKEY, [@@client_private_key].pack("H*").to_s)
  end

  def socket_tcp_keepalive
    socket.setsockopt(ZMQ::TCP_KEEPALIVE, 1)
    socket.setsockopt(ZMQ::TCP_KEEPALIVE_CNT, 5)
    socket.setsockopt(ZMQ::TCP_KEEPALIVE_IDLE, 60)
    socket.setsockopt(ZMQ::TCP_KEEPALIVE_INTVL, 60)
  end
end