module Fluent
  module StatsitePlugin
    class Metric
      TYPE = %w(kv g ms h c s)

      HASH_FIELD = %w(
        type
        key
        value
      )

      FIELD = '\w+|\$\{\w+\}'

      STRING_PATTERN = /^(#{FIELD}):(#{FIELD})\|(#{TYPE.join('|')})$/

      def initialize(key, value, type)
        @key = key
        @value = value
        @type = type
      end

      def convert(record)
        k = @key
        v = @value
        (k.nil? or v.nil?) ? nil : "#{k}:#{v}|#{@type}\n"
      end

      def to_s
        k = "key=#{@key}"
        v = "value=#{@value}"
        "Metric(#{k}, #{v}, type=#{@type})"
      end

      def self.validate(m)
        if not (m.class == Hash or m.class == String)
          raise ConfigError, "a type of metrics element must be Hash or String, but specified as #{m.class}"
        end

        case m
        when Hash
          m.keys.each do |k|
            if not HASH_FIELD.member?(k)
              raise ConfigError, "invalid metrics element hash key: #{k}"
            end
          end

          HASH_FIELD.each do |f|
            if not m.has_key?(f)
                raise ConfigError, "metrics element must contain '#{f}'"
            end
          end

          if not TYPE.member?(m['type'])
            raise ConfigError, "metrics type must be one of the following: #{TYPE.join(' ')}, but specified as #{m['type']}"
          end

          new(m['key'], m['value'], m['type'])
        when String
          if (STRING_PATTERN =~ m).nil?
            raise ConfigError, "metrics string must be #{STRING_PATTERN}, but specified as #{m}"
          end

          new($1, $2, $3)
        end
      end
    end
  end
end
