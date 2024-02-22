# frozen_string_literal: true

# Copyright (c) 2024 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'net/ssh'
require 'concurrent'

module Kexec
  class SSHExecutor
    def initialize(host, user, key_path, port=22)
      @host = host
      @user = user
      @key_path = key_path
      @port = port
    end

    def execute(command)
      Net::SSH.start(@host, @user, keys: [@key_path], port: @port) do |ssh|
        ssh.open_channel do |channel|
          channel.exec(command) do |_ch, success|
            raise "Failed to exec command: #{command}" unless success

            channel.on_data do |_ch, data|
              $stdout.print data
            end

            channel.on_extended_data do |_ch, _type, data|
              $stderr.print data
            end

            channel.on_request('exit-status') do |_ch, data|
              exit_code = data.read_long
              puts "Command exited with code: #{exit_code}"
            end
          end
        end

        ssh.loop
      end
    end
  end
end