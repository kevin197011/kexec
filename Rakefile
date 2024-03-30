# frozen_string_literal: true

# Copyright (c) 2024 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'time'

task default: %w[fmt push]

task :push do
  system 'git add .'
  system "git commit -m \"Update #{Time.now}.\""
  system 'git pull'
  system 'git push'
end

task :fmt do
  system 'rubocop -A'
end
