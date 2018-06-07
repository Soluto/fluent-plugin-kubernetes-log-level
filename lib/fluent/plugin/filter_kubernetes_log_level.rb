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
require "active_support/hash_with_indifferent_access"

module Fluent
  module Plugin
    class CaseInsensitiveHash < HashWithIndifferentAccess
      # This method shouldn't need an override, but my tests say otherwise.
      def [](key)
        super convert_key(key)
      end
    
      protected
    
      def convert_key(key)
        key.respond_to?(:downcase) ? key.downcase : key
      end  
    end

    class KubernetesLogLevelFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("kubernetes_log_level", self)

      # TODO - solve default values problem
      config_param :log_level_label, :string
      config_param :log_level_key, :string
      config_param :default_logging_level, :string

      def configure(conf)
          super
      end

      def level_to_num(level)
        case level
        when 'trace'
          10
        when 'debug'
          20
        when 'info'
          30
        when 'warning'
          40
        when 'error'
          50
        when 'fatal'
          60
        else
          0
        end
      end

      def filter(tag, time, record)
        
        h = CaseInsensitiveHash.new
        h = record
        puts(h["kubernetes".downcase])
        
        log.trace "Start to process record"
        is_logging_label_exist = false
        if record.has_key?("kubernetes")
          if record["kubernetes"].has_key?("labels")
            if record["kubernetes"]["labels"].has_key?(@log_level_label)
              log.trace "kubernetes.labels.logging-level found"
              numeric_logging_level = level_to_num(record['kubernetes']['labels'][@log_level_label])
              is_logging_label_exist = true
            end
          end
        end
        
        log.trace "Check for logging level existance"
        if is_logging_label_exist == false
          if @default_logging_level.nil?
            record
          else
            numeric_logging_level = level_to_num(@default_logging_level)
          end
        end
        
        log.trace "Process current log level"
        numeric_level = level_to_num(record[@log_level_key])
        if numeric_level >= numeric_logging_level
          record
        else
          nil
        end
      end
    end
  end
end
