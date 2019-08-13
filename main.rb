# frozen_string_literal: true

require "ffi-rzmq"
require "json"
require "yaml"

config_file = "config.yml"

yml_config = YAML.load_file(config_file)

def open_zmq_sock
  ctx = ZMQ::Context.new
  ctx.socket(ZMQ::REQ)
end

def socket_tcp_keepalive(socket)
  socket.setsockopt(ZMQ::TCP_KEEPALIVE, 1)
  socket.setsockopt(ZMQ::TCP_KEEPALIVE_CNT, 5)
  socket.setsockopt(ZMQ::TCP_KEEPALIVE_IDLE, 60)
  socket.setsockopt(ZMQ::TCP_KEEPALIVE_INTVL, 60)
end

def socket_encryption(socket, server_public_key, client_public_key, client_private_key)
  socket.setsockopt(ZMQ::CURVE_SERVER, 0)
  socket.setsockopt(ZMQ::CURVE_SERVERKEY, [server_public_key].pack("H*").to_s)
  socket.setsockopt(ZMQ::CURVE_PUBLICKEY, [client_public_key].pack("H*").to_s)
  socket.setsockopt(ZMQ::CURVE_SECRETKEY, [client_private_key].pack("H*").to_s)
end

def random_identity
  (0..31).map { rand(69..91).chr }.join
end

def socket_option(zmq_socket, server_public_key, client_public_key, client_private_key)
  socket_encryption(zmq_socket, server_public_key, client_public_key, client_private_key)
  zmq_socket.setsockopt(ZMQ::IMMEDIATE, 1)
  zmq_socket.setsockopt(ZMQ::IDENTITY, random_identity)
  zmq_socket.setsockopt(ZMQ::REQ_CORRELATE, 1)
  zmq_socket.setsockopt(ZMQ::REQ_RELAXED, 1)

  socket_tcp_keepalive(zmq_socket)
  zmq_socket.setsockopt(ZMQ::MAXMSGSIZE, 5_000_000)
end

def open_sock(address, server_public_key, client_public_key, client_private_key)
  s = open_zmq_sock
  socket_option(s, server_public_key, client_public_key, client_private_key)
  s.connect(address)
  s
end

def connection(ip, port)
  "tcp://#{ip}:#{port}"
end

sockets = []

yml_config["nodes"].each do |n|
  sockets << open_sock(connection(n["ip4"], n["port"]), n["public_key"], yml_config["public_key"], yml_config["private_key"])
end

def parse_response(resp)
  hsh = JSON.parse(resp).to_h
  puts "response: #{hsh}"
end

sockets.each do |s|
  s.send_string("testing", ZMQ::SNDMORE)
  s.send_string("I", 0)
  msgs = []
  s.recv_strings(msgs)
  parse_response(msgs[1])
end

sockets.each(&:close)

