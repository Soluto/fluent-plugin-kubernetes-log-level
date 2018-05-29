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

You can generate configuration template:

```
$ fluent-plugin-config-format filter kubernetes-log-level
```
TODO - generate this doc once the plugin is published

You can copy and paste generated documents here.

## Copyright

* Copyright(c) 2018- yaron-idan
* License
  * Apache License, Version 2.0

