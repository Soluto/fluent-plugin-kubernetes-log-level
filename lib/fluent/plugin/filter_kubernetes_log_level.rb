#
# Copyright 2018- yaron-idan
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/filter"

module Fluent
  module Plugin
    class KubernetesLogLevelFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("kubernetes_log_level", self)

      config_param :log_level_label, :string, :default => 'logging-level'
      config_param :log_level_key_label, :string, :default => 'logging-level-key'
      config_param :default_log_level_key, :string, :default => 'level'
      config_param :default_logging_level, :string, :default => ''

      def configure(conf)
          super
      end

      def level_to_num(level)
        if not level.is_a? String
          return level.to_i
        end

        case level.downcase
        when 'trace', 'verbose'
          10
        when 'debug'
          20
        when 'info', 'information'
          30
        when 'warning', 'warn'
          40
        when 'error'
          50
        when 'fatal'
          60
        else
          level.to_i
        end
      end

      def filter(tag, time, record)
        
        log.trace "Start to process record"

        log_level_key = @default_log_level_key
        logging_level = @default_logging_level
        app = 'app'

        if record.has_key?("kubernetes")
          if record["kubernetes"].has_key?("labels")
            if record["kubernetes"]["labels"].has_key?('app')
              app = record['kubernetes']['labels']['app']
            end

            if record["kubernetes"]["labels"].has_key?(@log_level_key_label)
              log_level_key = record['kubernetes']['labels'][@log_level_key_label]
              log.debug "[App: #{app}]: kubernetes.labels.#{@log_level_key_label} found with the value #{log_level_key}"
            end

            if record["kubernetes"]["labels"].has_key?(@log_level_label)
              logging_level = record['kubernetes']['labels'][@log_level_label]
              log.debug "[App: #{app}]: kubernetes.labels.#{@log_level_label} found with the value #{logging_level}"
            end
          end
        end

        numeric_logging_level = level_to_num(logging_level)

        log.trace "Process current log level"
        
        if record.has_key?(log_level_key.capitalize)
          log.debug "[App: #{app}]: Downcasing capitalized log_level from #{log_level_key.capitalize}"
          current_log_level = record[log_level_key.capitalize]
        elsif record.has_key?(log_level_key)
          current_log_level = record[log_level_key]
        else
          log.warn "[App: #{app}]: log level key #{log_level_key} not found in record"
          return nil
        end
        
        numeric_level = level_to_num(current_log_level)
        if numeric_level >= numeric_logging_level
          log.debug "[App: #{app}]: Emitting record with #{current_log_level} level"
          record
        else
          log.debug "[App: #{app}]: Dropping record with #{current_log_level} level"
          nil
        end
      end
    end
  end
end
