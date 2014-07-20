require 'helper'
require 'fluent/plugin/statsite/format'

include Fluent::StatsitePlugin

class StatsiteFormatterTest < Test::Unit::TestCase
  def setup
    metrics = [
      Metric.validate('${k}:${v}|g'),
      Metric.validate('${k}:v|g')
    ]
    @formatter = StatsiteFormatter.new(metrics)
  end

  def test_call
    record = {'v' => 'value'}
    assert_equal "", @formatter.call(record)

    record = {'k' => 'key'}
    assert_equal "key:v|g\n", @formatter.call(record)

    record = {'k' => 'key', 'v' => 'value'}
    assert_equal "key:value|g\nkey:v|g\n", @formatter.call(record)
  end
end
