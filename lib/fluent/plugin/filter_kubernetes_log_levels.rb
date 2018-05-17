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
    class KubernetesLogLevelsFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("kubernetes_log_levels", self)


      config_param :log_level_label, :string,  :default => 'logging-level'
      config_param :log_level_key, :string, :default => 'level'
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
        numeric_logging_level = 0
        if record.has_key?("kubernetes")
          if record["kubernetes"].has_key?("labels")
            if record["kubernetes"]["labels"].has_key?(@log_level_label)
              numeric_logging_level = level_to_num(record['kubernetes']['labels'][@log_level_label])
            end
          end
        end
        if numeric_logging_level === 0
          record
        else
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
end
