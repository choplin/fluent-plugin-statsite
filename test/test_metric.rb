require 'helper'
require 'fluent/plugin/statsite/metric'

include Fluent::StatsitePlugin

class Metric
  attr_reader :key, :key_field, :value, :value_field, :type
end

class MetricTest < Test::Unit::TestCase

  def valid_config
    {'key' => 'k', 'value' => 'v', 'type' => 'kv'}
  end

  def test_validate_object_type
    config = []
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }
  end

  def test_validate_extra_field
    config = valid_config
    config['foo'] = 'bar'
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }
  end

  def test_validate_key
    config = (valid_config)['key_field'] = 'k'
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }

    config = (valid_config)
    config.delete('key')
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }
  end

  def test_validate_value
    config = (valid_config)['value_field'] = 'k'
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }

    config = (valid_config)
    config.delete('value')
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }
  end

  def test_validate_type
    config = (valid_config)
    config.delete('type')
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }

    config = (valid_config)
    config['type'] = 'foo'
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }
  end

  def test_validate_string
    config = "foo"
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }

    config = "k:v|foo"
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }
  end

  def test_validate_result
    m = Metric.validate(valid_config)
    assert_equal 'k', m.key
    assert_nil m.key_field
    assert_equal 'v', m.value
    assert_nil m.value_field
    assert_equal 'kv', m.type
  end

  def test_validate_result_string
    m = Metric.validate('k:v|kv')
    assert_equal 'k', m.key
    assert_nil m.key_field
    assert_equal 'v', m.value
    assert_nil m.value_field
    assert_equal 'kv', m.type

    m = Metric.validate('${k}:${v}|kv')
    assert_nil m.key
    assert_equal 'k', m.key_field
    assert_nil m.value
    assert_equal 'v', m.value_field
    assert_equal 'kv', m.type
  end

  def test_convert
    m = Metric.validate('${k}:${v}|kv')

    record = {'k' => 'key'}
    assert_nil m.convert(record)

    record = {'v' => 'value'}
    assert_nil m.convert(record)

    record = {'k' => 'key', 'v' => 'value'}
    assert_equal "key:value|kv\n", m.convert(record)
  end
end
