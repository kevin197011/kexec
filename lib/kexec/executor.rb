# frozen_string_literal: true

# Copyright (c) 2024 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'net/ssh'
require 'net/scp'

module Kexec
  class SSHExecutor
    def initialize(host, user, key_path, port = 22, timeout = 10)
      @host = host
      @user = user
      @key_path = key_path
      @port = port
      @timeout = timeout
    end

    def execute!(cmd)
      options = {
        timeout: @timeout
      }

      Net::SSH.start(@host, @user, keys: [@key_path], port: @port, optins: options) do |ssh|
        ssh.open_channel do |channel|
          channel.exec(cmd) do |_ch, success|
            raise "[#{@host}] failed to exec command: #{command}" unless success

            channel.on_data do |_ch, data|
              $stdout.print "  [#{@host}] => #{data}"
            end

            channel.on_extended_data do |_ch, _type, data|
              $stderr.print "  [#{@host}] => #{data}"
            end

            channel.on_request('exit-status') do |_ch, data|
              exit_code = data.read_long
              puts "[#{@host}] command exited with code: #{exit_code}"
            end
          end
        end

        ssh.loop
      end
    end

    def upload!(file, remote_file)
      options = {
        timeout: @timeout
      }

      Net::SSH.start(@host, @user, keys: [@key_path], port: @port, optins: options) do |ssh|
        ssh.exec!("rm -rf #{remote_file}")
      end

      Net::SCP.start(@host, @user, keys: [@key_path], port: @port, optins: options) do |scp|
        scp.upload!("#{__dir__}/../../script/#{file}", remote_file)
      end
    end
  end
end
