# frozen_string_literal: true

require 'pry'
require 'colorize'

module Command
  # info - get bitmarkd info
  class Base
    def info
      parse_info(rpc.info)
    end

    private

    def parse_info (json)
      hsh = json.to_h
      err = hsh['error']
      if err.nil?
        result = hsh['result']
        version = result['version'].ljust(version_length)
        hash_rate = result['hashrate']
        chain = result['chain'].ljust(chain_length)
        pending_count = result['transactionCounters']['pending'].to_s.ljust(5)
        verified_count = result['transactionCounters']['verified'].to_s.ljust(5)

        status = 'N'.colorize(:blue)
        status = 'R'.colorize(:red) if result['mode'].downcase != 'normal'
        "#{name.ljust(name_length)} #{version} #{chain} #{status} p:#{pending_count} v:#{verified_count} #{hash_rate}"
      else
        puts "get rpc info with error: #{err}"
        ""
      end
    end

    def info_prefix
      'I'
    end

    def version_length
      10
    end

    def chain_length
      8
    end

    def name_length
      5
    end
  end
end
