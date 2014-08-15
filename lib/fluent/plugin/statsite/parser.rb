module Fluent
  module StatsitePlugin
    module Parser
      def parse_line(line)
        k,v,t = line.chomp.split('|')
        record = build_record(k,v)
        [t.to_i, record]
      end

      def build_record(k,v)
        type, key, statistic, range = k.split(".", 4)

        case type
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
      end
    end

    class StatsiteParser
      include Parser

      def initialize(on_message)
        @on_message = on_message
      end

      def call(io)
        io.each_line(&method(:each_line))
      end

      def each_line(line)
        time, record = parse_line(line)
        raise "out_statsite: failed to parse a line. '#{line}'" if record.nil?

        @on_message.call(time, record)
      end
    end

    class StatsiteAggregateParser
      # TODO: should be configurable?
      FLUSH_WAIT = 0.5

      def initialize(on_message, coolio_loop)
        @on_message = on_message
        @loop = coolio_loop
        @buf = {}
      end

      def call(io)
        io.each_line(&method(:each_line))
      end

      def each_line(line)
        record = parse_line(line)

        raise "out_statsite: failed to parse a line. '#{line}'" if record.nil?

        timer = TimerWatcher(FLUSH_WAIT, $log, method(&:flush))
      end

      def flush
        @on_message.call(t.to_i, record)
      end

      class TimerWatcher < Coolio::TimerWatcher
        def initialize(duration, log, callback)
          @callback = callback
          @log = log
          super(interval, repeat)
        end

        def on_timer
          @callback.call
        rescue
          @log.error $!.to_s
          @log.error_backtrace
        end
      end
    end
  end
end
