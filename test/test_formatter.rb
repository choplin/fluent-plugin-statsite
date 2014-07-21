require 'helper'
require 'fluent/plugin/statsite/format'

include Fluent::StatsitePlugin

class StatsiteFormatterTest < Test::Unit::TestCase
  def setup
    metrics = [
      Metric.validate('test_${k}:test_${v}|g'),
      Metric.validate('test_${k}:test_v|g')
    ]
    @formatter = StatsiteFormatter.new(metrics)
  end

  def test_call
    record = {'v' => 'value'}
    assert_equal "", @formatter.call(record)

    record = {'k' => 'key'}
    assert_equal "test_key:test_v|g\n", @formatter.call(record)

    record = {'k' => 'key', 'v' => 'value'}
    assert_equal "test_key:test_value|g\ntest_key:test_v|g\n", @formatter.call(record)
  end
end
