module Fluent
  module StatsitePlugin
    class StatsiteParser
      def initialize(on_message)
        @on_message = on_message
      end

      def call(io)
        io.each_line(&method(:each_line))
      end

      def each_line(line)
        k,v,t = line.chomp.split('|')
        type, key, statistic, range = k.split(".", 4)

        record = case type
                 when 'timers' then 1
                   if statistic == 'histogram'
                     {type: type, key: key, value: v.to_i, statistic: statistic, range: range[4..-1]}
                   elsif statistic == 'count'
                     {type: type, key: key, value: v.to_i, statistic: statistic}
                   else
                     {type: type, key: key, value: v.to_f, statistic: statistic}
                   end
                 when 'kv', 'gauges', 'counts'
                   {type: type, key: key, value: v.to_f}
                 when 'sets'
                   {type: type, key: key, value: v.to_i}
                 end

        raise "out_statsite: failed to parse a line. '#{line}'" if record.nil?

        @on_message.call(t.to_i, record)
      end
    end

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
