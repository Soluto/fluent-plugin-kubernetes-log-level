https://travis-ci.com/Soluto/fluent-plugin-kubernetes-log-level.svg?branch=master

# fluent-plugin-kubernetes-log-level

[Fluentd](https://fluentd.org/) filter plugin to filter messages according to log level

This plugin allows setting a kubernetes label to your pods, and have fluentd filter logs containing a level value lower then the level indicated by the label.

## Installation

### RubyGems

```
$ gem install fluent-plugin-kubernetes-log-level
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-kubernetes-log-level"
```

And then execute:

```
$ bundle
```

## Configuration

Configuration options for fluent.conf are:

* `log_level_label` - kubernetes label name for setting current log level
* `log_level_key` - key in log record to indicate the current record's level
* `default_logging_level` - default logging levels for kubernetes services missing a `log_level_label`

## Copyright

* Copyright(c) 2018- yaron-idan
* License
  * Apache License, Version 2.0

