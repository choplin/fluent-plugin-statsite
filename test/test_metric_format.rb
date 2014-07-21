require 'helper'
require 'fluent/plugin/statsite/metric_format'

include Fluent::StatsitePlugin

class MetricFormat
  attr_reader :str, :no_substitute
end

class MetricFormatTest < Test::Unit::TestCase
  def test_validate
    assert_raises(Fluent::ConfigError) { MetricFormat.validate('()') }
    assert_raises(Fluent::ConfigError) { MetricFormat.validate('$') }
    assert_raises(Fluent::ConfigError) { MetricFormat.validate('{}}') }
  end

  def test_validate_result
    s = 'foo_${bar}_foobar'
    mf = MetricFormat.validate(s)
    assert_equal s, mf.str
    assert (not mf.no_substitute)

    s = 'foo_bar_foobar'
    mf = MetricFormat.validate(s)
    assert_equal s, mf.str
    assert mf.no_substitute
  end

  def test_validate_convert
    s = 'foo_${bar}_foobar'
    mf = MetricFormat.validate(s)

    assert_equal 'foo_hoge_foobar', mf.convert({'bar' => 'hoge'})

    assert_nil mf.convert({'hoge' => 'fuga'})
  end
end
