# frozen_string_literal: true

# Copyright (c) 2024 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'concurrent'
require 'colorize'
require_relative 'executor'

module Kexec
  class SSHRunner
    @@max_concurrency = 5
    @@semaphore = Concurrent::Semaphore.new(@@max_concurrency)

    def self.run
      config = Kexec::SSHConfig.load("#{__dir__}/../../config/kexec.yml")

      self.banner
      threads = config['hosts'].map do |host|
        Thread.new do
          @@semaphore.acquire
          begin
            runner = Kexec::SSHExecutor.new(host, config['user'], config['key_path'], config['port'])
            runner.upload!(config['script_path'])
            runner.execute("sudo bash /tmp/#{config['script_path']}")
            runner.execute("sudo rm -rf /tmp/#{config['script_path']}")
          ensure
            @@semaphore.release
          end
        end
      end

      threads.each(&:join)
    end

    private
    def self.banner
      puts '
        _  __
        | |/ /_____  _____  ___
        | ' // _ \ \/ / _ \/ __|
        | . \  __/>  <  __/ (__
        |_|\_\___/_/\_\___|\___|
                      running...
      '
    end
  end
end
