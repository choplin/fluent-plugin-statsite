# Statsite Fluentd Plugin

This plugin calculates various useful metrics using [Statsite by armon](http://armon.github.io/statsite/).

 [Statsite](http://armon.github.io/statsite/) is very cool software. Statsite works as daemon service, receiving events from tcp/udp, aggregating these events with specified methods, and sending the results via pluggable sinks. Statsite is written in C, cpu and memory efficient, and employ some approximate algorithms for unique sets and percentiles.

 You may think this as standard output plugin which just sends events to a daemon process, such as [mongodb plugin](https://github.com/fluent/fluent-plugin-mongo). It is true that this plugin is registered as output plugin, but this works as the so-called **Filter Plugin**, which means that this plugin sends matched events to Statsite process, recieves results aggregated by the Statsite, then re-emitting these results as events.

 Statsite process is launched as a child process from this plugin internally. Only you have to do place statsite the binary under $PATH, or set the path of statsite binary as parameter. Neither config files or daemon process is not required. Besides, the communication between the plugin and the Statsite process takes place through STDIN/STDOUT, so no network port will be used.

## Installation

`$ fluent-gem install fluent-plugin-statsite`

### Statsite Installation

 Statsite can work as sinble binary with few dependency. You probably could get it working just by downloading source files and executing make command.

Please refer to [Statsite official page](http://armon.github.io/statsite/).

## Configuration

It is strongly recommended to use '[V1 config format](http://docs.fluentd.org/articles/config-file#v1-format)' because this plugin requires to set deeply nested parameters. 

### Example

```
<match **>
  type statsite
  tag statsite
  metrics [
    "${status}:1|c",
    {"key": "request_time", "value_field": "request_time", "type": "ms"}
  ]
  histograms [
    {"prefix": "request_time" "min": 0, "max": 1, "width": 0.1}
  ]
  statsite_path "statsite"
  statsite_flush_interval 1s
  timer_eps 0.01
  set_eps 0.01
  child_respawn 5
</match>
```

### Parameter

TODO

### Metrics Format

You can specify metrics in two format, string style, and hash style.

#### String style

TODO

#### Hash style

TODO

## Copyright

* Copyright (c) 2014- OKUNO Akihiro
* License
    * Apache License, version 2.0
