# frozen_string_literal: true

# Copyright (c) 2024 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'concurrent'
require_relative 'ssh-executor'

module Kexec
  class SSHRunner
    @@max_concurrency = 5
    @@semaphore = Concurrent::Semaphore.new(@@max_concurrency)

    def self.run(cmd)
      config = Kexec::SSHConfig.load("#{__dir__}/../../config/config.yml")
      threads = config['hosts'].map do |host|
        Thread.new do
          @@semaphore.acquire
          begin
            runner = Kexec::SSHExecutor.new(host, config['user'], keys: [config['key_path']], port: config['port'])
            runner.execute(cmd)
          ensure
            @@semaphore.release
          end
        end
      end
      threads.each(&:join)
    end
  end
end
