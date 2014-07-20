module Fluent
  module StatsitePlugin
    class Histogram
      FIELD = %w(
        min
        max
        width
      )

      OPTIONAL_FIELD = %w(prefix)

      FLOATING_FIELD = %w(
        min
        max
        width
      )

      def initialize(prefix, min, max, width)
        @prefix = prefix
        @min = min
        @max = max
        @width = width

        @section = prefix.nil? ? "default" : prefix
      end

      def to_ini
        <<-INI
[histogram_#{@section}]
prefix=#{@prefix}
min=#{@min}
max=#{@max}
width=#{@width}
        INI
      end

      def self.validate(h)
        if h.class != Hash
          raise ConfigError, "a type of histogram element must be Hash, but specified as #{h.class}"
        end

        FIELD.each do |f|
          if not h.has_key?(f)
            raise ConfigError, "histogram element must contain '#{f}'"
          end
        end

        h.keys.each do |k|
          if not FIELD.member?(k) and not OPTIONAL_FIELD.member?(k)
            raise ConfigError, "invalid histogram hash key: #{k}"
          end
        end

        FLOATING_FIELD.each do |f|
          cls = h[f].class
          if cls != Fixnum and cls != Float
            raise ConfigError, "#{f} value of histogram must be Fixnum or Float"
          end
        end

        new(h['prefix'], h['min'], h['max'], h['width'])
      end
    end
  end
end
