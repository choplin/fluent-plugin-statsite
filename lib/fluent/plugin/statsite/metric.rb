module Fluent
  module StatsitePlugin
    class Metric
      TYPE = %w(kv g ms h c s)

      HASH_FIELD = %w(
        type
        key
        key_field
        value
        value_field
      )

      FIELD = '\w+|\$\{\w+\}'

      STRING_PATTERN = /^(#{FIELD}):(#{FIELD})\|(#{TYPE.join('|')})$/
      STRING_EXAMPLE = "key_field:value_field|type"

      def initialize(key, key_field, value, value_field, type)
        @key = key
        @key_field = key_field
        @value = value
        @value_field = value_field
        @type = type
      end

      def convert(record)
        k = @key.nil? ? record[@key_field] : @key
        v = @value.nil? ? record[@value_field] : @value
        (k.nil? or v.nil?) ? nil : "#{k}:#{v}|#{@type}\n"
      end

      def to_s
        k = @key.nil? ? "key_field=#{@key_field}" :"key=#{@key}"
        v = @value.nil? ? "value_field=#{@value_field}" :"value=#{@value}"
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

          if not m.has_key?('key') ^ m.has_key?('key_field')
              raise ConfigError, "metrics element must contain either one of 'key' or 'key_field'"
          end

          if not m.has_key?('value') ^ m.has_key?('value_field')
              raise ConfigError, "metrics element must contain either one of 'value' or 'value_field'"
          end

          if not m.has_key?('type')
              raise ConfigError, "metrics element must contain 'type'"
          end

          if not TYPE.member?(m['type'])
            raise ConfigError, "metrics type must be one of the following: #{TYPE.join(' ')}, but specified as #{m['type']}"
          end

          new(m['key'], m['value_field'], m['value'], m['value_field'], m['type'])
        when String
          if (STRING_PATTERN =~ m).nil?
            raise ConfigError, "metrics string must be #{STRING_PATTERN}, but specified as #{m}"
          end

          key, key_field = $1.start_with?('$') ? [nil, $1[2..-2]] : [$1, nil]
          value, value_field = $2.start_with?('$') ? [nil, $2[2..-2]] : [$2, nil]
          new(key, key_field, value, value_field, $3)
        end
      end
    end
  end
end
