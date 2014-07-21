require 'helper'
require 'fluent/plugin/statsite/metric'

include Fluent::StatsitePlugin

class Metric
  attr_reader :key, :value, :type
end

class MetricTest < Test::Unit::TestCase

  def valid_config
    {'key' => 'test_${k}', 'value' => 'test_${v}', 'type' => 'kv'}
  end

  def invalid_kv_format
    'test_${'
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
    config = (valid_config)
    config.delete('key')
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }

    # invalid key format
    config = valid_config
    config['key'] = invalid_kv_format
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }
  end

  def test_validate_value
    config = (valid_config)
    config.delete('value')
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }

    # invalid value format
    config = valid_config
    config['key'] = invalid_kv_format
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

  def test_validate_deprecated
    config = valid_config
    config.delete('value')
    config['value_field'] = 'v'
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }

    config = valid_config
    config.delete('key')
    config['key_field'] = 'k'
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }
  end

  def test_validate_string
    config = "foo"
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }

    # invalid type
    config = "k:v|foo"
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }

    # invalid key format
    config = "${k:v|foo"
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }

    # invalid value format
    config = "k:v_()|foo"
    assert_raises(Fluent::ConfigError) { Metric.validate(config) }
  end

  def test_validate_result
    m = Metric.validate(valid_config)
    assert_equal 'test_${k}', m.key.to_s
    assert_equal 'test_${v}', m.value.to_s
    assert_equal 'kv', m.type
  end

  def test_validate_result_string
    m = Metric.validate('test_${k}:test_${v}|kv')
    assert_equal 'test_${k}', m.key.to_s
    assert_equal 'test_${v}', m.value.to_s
    assert_equal 'kv', m.type
  end

  def test_convert
    m = Metric.validate('test_${k}:test_${v}|kv')

    record = {'k' => 'key'}
    assert_nil m.convert(record)

    record = {'v' => 'value'}
    assert_nil m.convert(record)

    record = {'k' => 'key', 'v' => 'value'}
    assert_equal "test_key:test_value|kv\n", m.convert(record)
  end

  def test_convert_constant
    m = Metric.validate('k:v|kv')
    record = {}
    assert_equal "k:v|kv\n", m.convert(record)
  end
end
