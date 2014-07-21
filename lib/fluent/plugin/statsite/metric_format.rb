module Fluent
  module StatsitePlugin
    # This represent a key/value format of Metric
    class MetricFormat
      CONSTANT_VALUE = '\w+'
      SUBSTITUTE = '\$\{\w+\}'
      SUBSTITUTE_REGEXP = /\$\{(\w+)\}/
      ELEMENT = "(?:#{CONSTANT_VALUE}|#{SUBSTITUTE})"
      PATTERN = "#{ELEMENT}+"

      def initialize(str)
        @str = str
        @no_substitute = str.index('$').nil?
      end

      def convert(record)
        if @no_substitute
          @str
        else
          @str.gsub(SUBSTITUTE_REGEXP) { record.fetch($1) } rescue nil
        end
      end

      def to_s
        @str
      end

      def self.validate(str)
        if /^#{PATTERN}$/.match(str).nil?
          raise ConfigError, "invalid format of key/value field, it must be #{PATTERN}, but specified as #{str}"
        end

        new(str)
      end
    end
  end
end
