require 'helper'
require 'fluent/plugin/statsite/histogram'

include Fluent::StatsitePlugin

class Histogram
  attr_reader :section, :prefix, :min, :max, :width
end

class HistogramTest < Test::Unit::TestCase
  def valid_config
    {
      'prefix' => 'pre',
      'min' => 0.0,
      'max' => 10.0,
      'width' => 1.0,
    }
  end

  def test_validate_object_type
    config = []
    assert_raises(Fluent::ConfigError) { Histogram.validate(config) }
  end

  def test_validate_mandatory_field
    Histogram::FIELD.each do |f|
      config = valid_config
      config.delete(f)
      assert_raises(Fluent::ConfigError) { Histogram.validate(config) }
    end
  end

  def test_validate_extra_field
    config = valid_config
    config['foo'] = 'bar'
    assert_raises(Fluent::ConfigError) { Histogram.validate(config) }
  end

  def test_validate_floating_field
    Histogram::FLOATING_FIELD.each do |f|
      config = valid_config
      config[f] = 'foo'
      assert_raises(Fluent::ConfigError) { Histogram.validate(config) }
    end
  end

  def test_validate_result
    c = valid_config
    h = Histogram.validate(c)
    assert_equal c['prefix'], h.section
    assert_equal c['prefix'], h.prefix
    assert_equal c['min'], h.min
    assert_equal c['max'], h.max
    assert_equal c['width'], h.width
  end

  def test_to_init
    c = valid_config

    ini = Histogram.validate(c).to_ini
    assert_equal ini, <<-INI
[histogram_#{c['prefix']}]
prefix=#{c['prefix']}
min=#{c['min']}
max=#{c['max']}
width=#{c['width']}
    INI

    c.delete('prefix')
    ini = Histogram.validate(c).to_ini
    assert_equal ini, <<-INI
[histogram_default]
prefix=
min=#{c['min']}
max=#{c['max']}
width=#{c['width']}
    INI
  end
end
