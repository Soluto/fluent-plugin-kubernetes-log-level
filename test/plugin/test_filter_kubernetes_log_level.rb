require "helper"
require "fluent/plugin/filter_kubernetes_log_level.rb"

class KubernetesLogLevelFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
    @expected_warning = [{
      'level'      => 'warning',
      'kubernetes' => {
        'labels' => {
          'logging-level' => 'warning',
          'app' => 'demo'
        }
      }
    }]
    
    @expected_error = [{
      'level'  => 'error',
      'kubernetes' => {
        'labels' => {
          'logging-level' => 'warning',
          'app' => 'demo'
        }
      }
    }]

    @expected_info = []

    @expected_static_warning_default = [{
      'level' => 'warning',
      'kubernetes' => {
        'labels' => {
          'app' => 'demo'
        }
      }
    }]


    @expected_static_capital_level = [{
      'Level' => 'Warning',
      'level' => 'Warning',
      'kubernetes' => {
        'labels' => {
          'app' => 'demo'
        }
      }
    }]

    @expected_warning_serilog = [{
      'level'      => 'Warning',
      'kubernetes' => {
        'labels' => {
          'logging-level' => 'Warning',
          'app' => 'demo'
        }
      }
    }]

    @expected_no_default_log_level = [{
      'level'  => 'error',
      'kubernetes' => {
        'labels' => {
          'app' => 'demo'
        }
      }
    }]

    @expected_log_level_key = [{
      'levelname'  => 'error',
      'kubernetes' => {
        'labels' => {
          'logging-level-key' => 'levelname',
          'app'               => 'demo'
        }
      }
    }]
  end

  CONFIG = %[
    default_logging_level warning
  ]

 # private

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::KubernetesLogLevelFilter).configure(conf)
  end

  def filter(msg, conf = CONFIG, time = event_time("2017-07-12 19:20:21 UTC"))
    d = create_driver(conf)
    d.run { d.feed('kubernetes', time, msg) }
    d.filtered_records
  end

  def test_default_configuration
    conf = %[
      log_level_label logging-level
      log_level_key_label logging-level-key
      default_log_level_key level
      default_logging_level warning
    ]
  
    d = create_driver(conf)
    assert_equal 'logging-level', d.instance.config['log_level_label']
    assert_equal 'logging-level-key', d.instance.config['log_level_key_label']
    assert_equal 'level', d.instance.config['default_log_level_key']
    assert_equal 'warning', d.instance.config['default_logging_level']
  end

  def test_log_level_higher_then_threshold
    assert_equal @expected_error, filter({"level"=>"error", "kubernetes"=>{"labels"=>{"logging-level"=>"warning","app"=>"demo"}}})
  end 

  def test_log_level_equal_to_threshold
    assert_equal @expected_warning, filter({"level"=>"warning", "kubernetes"=>{"labels"=>{"logging-level"=>"warning","app"=>"demo"}}})
  end 

  def test_log_level_lower_then_threshold
    assert_equal @expected_info, filter({"level"=>"info", "kubernetes"=>{"labels"=>{"logging-level"=>"warning","app"=>"demo"}}})
  end 

  def test_static_log
    assert_equal @expected_static_warning_default, filter({"level"=>"warning", "kubernetes"=>{"labels"=>{"app"=>"demo"}}})
  end

  def test_serilog_structure
    assert_equal @expected_static_capital_level, filter({"Level"=>"Warning", "kubernetes"=>{"labels"=>{"app"=>"demo"}}})
  end

  def test_no_default_log_level
    conf = %[]
    assert_equal @expected_no_default_log_level, filter({"level"=>"error", "kubernetes"=>{"labels"=>{"app"=>"demo"}}}, conf)
  end

  def test_custom_log_level
    assert_equal @expected_log_level_key, filter({"levelname"=>"error", "kubernetes"=>{"labels"=>{"logging-level-key"=>"levelname","app"=>"demo"}}})
  end
end
