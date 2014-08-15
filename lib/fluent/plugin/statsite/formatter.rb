module Fluent
  module StatsitePlugin
    class StatsiteFormatter
      def initialize(metrics)
        @metrics = metrics
      end

      def call(record)
        @metrics.map{|m| m.convert(record)}.select{|m| not m.nil?}.join('')
      end
    end
  end
end
