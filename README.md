# Statsite Fluentd Plugin

[![Build Status](https://travis-ci.org/choplin/fluent-plugin-statsite.svg?branch=master)](https://travis-ci.org/choplin/fluent-plugin-statsite)

This plugin calculates various useful metrics using [Statsite by armon](http://armon.github.io/statsite/).

 [Statsite](http://armon.github.io/statsite/) is very cool software. Statsite works as daemon service, receiving events from tcp/udp, aggregating these events with specified methods, and sending the results via pluggable sinks. Statsite is written in C, cpu and memory efficient, and employ some approximate algorithms for unique sets and percentiles.

 You may think this as standard output plugin which just sends events to a daemon process, such as [mongodb plugin](https://github.com/fluent/fluent-plugin-mongo). It is true that this plugin is registered as output plugin, but this works as the so-called **Filter Plugin**, which means that this plugin sends matched events to Statsite process, recieves results aggregated by the Statsite, then re-emitting these results as events.

 Statsite process is launched as a child process from this plugin internally. All you have to do place statsite the binary under $PATH, or set the path of statsite binary as parameter. Neither config files or daemon process is not required. Besides, the communication between the plugin and the Statsite process takes place through STDIN/STDOUT, so no network port will be used.

## Quickstart

Assume that nginx log events like below come.

```json
{
  "remote_addr":"114.170.6.118",
  "remote_user":"-",
  "time_local":"20/Jul/2014:18:25:50 +0000",
  "request":"GET /foo HTTP/1.1",
  "status":"200",
  "body_bytes_sent":"911",
  "http_referer":"-",
  "http_user_agent":"Mozilla/5.0 (Linux; U; Android 4.2.2; ja-jp; SO-04E Build/10.3.1.B.0.256) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
  "request_time":"0.058",
  "upstream_addr":"192.168.222.180:80",
  "upstream_response_time":"0.058"
}
```

and you set a fluentd config as,

```
<match **>
  type statsite_filter
  tag statsite
  metrics [
    "status_${status}:1|c",
    "request_time|${request_time}|ms"}
  ]
  histograms [
    {"prefix": "request_time", "min": 0, "max": 1, "width": 0.1}
  ]
  statsite_path "statsite"
  statsite_flush_interval 1s
  timer_eps 0.01
  set_eps 0.01
  child_respawn 5
  flush_interval 1s
</match>
```

then you will get events such as below every specified seconds.

```json
{"type":"counts","key":"status_500","value":1.0}
{"type":"counts","key":"status_200","value":3.0}
{"type":"counts","key":"status_302","value":1.0}
{"type":"timers","key":"request_time","value":12.0,"statistic":"sum"}
{"type":"timers","key":"request_time","value":40.0,"statistic":"sum_sq"}
{"type":"timers","key":"request_time","value":2.4,"statistic":"mean"}
{"type":"timers","key":"request_time","value":1.0,"statistic":"lower"}
{"type":"timers","key":"request_time","value":5.0,"statistic":"upper"}
{"type":"timers","key":"request_time","value":5,"statistic":"count"}
{"type":"timers","key":"request_time","value":1.67332,"statistic":"stdev"}
{"type":"timers","key":"request_time","value":2.0,"statistic":"median"}
{"type":"timers","key":"request_time","value":5.0,"statistic":"p95"}
{"type":"timers","key":"request_time","value":5.0,"statistic":"p99"}
{"type":"timers","key":"request_time","value":12.0,"statistic":"rate"}
```

## Prerequisite

You have to install Statsite on the machine where fluentd is running.

## Installation

`$ fluent-gem install fluent-plugin-statsite`

### Statsite Installation

 Statsite can work as sinble binary with few dependency. You probably could get it working just by downloading source files and executing make command.

Please refer to [Statsite official page](http://armon.github.io/statsite/).

## Configuration

It is strongly recommended to use '[V1 config format](http://docs.fluentd.org/articles/config-file#v1-format)' because this plugin requires to set deeply nested parameters.

### Example

### Parameter

key                     | type   | description | required | default
---                     | ---    | ---         | ---      | ---
tag                     | string |             | yes      |
metrics                 | array  |             | yes      |
histograms              | array  |             | no       | []
statiste_path           | string |             | yes      | statsite
statsite_flush_interval | time   |             | no       | 10s
time_eps                | float  |             | no       | 0.01
set_eps                 | float  |             | no       | 0.02
child_respawn           | string |             | no       |

### Metrics Format

You can specify metrics in two format, string style, and hash style.

#### String style

##### Example

```
"status_${status}:1|c"
```

TODO

#### Hash style

##### Example

```json
{"key": "status_${status}", "value": "1", "type": "c"}
```
##### Fields

key        | description | required
---        | ---         | ---
key        |             | yes
value_time |             | yes
type       |             | yes

#### Variable substitution

*TODO*

### Histograms Format

#### Example

```json
{"prefix": "request_time", "min": 0, "max": 1, "width": 0.1}
```

#### Fields

TODO

key          | description | required
---          | ---         | ---
prefix       |             | no
request_time |             | yes
min          |             | yes
max          |             | yes
width        |             | yes

## Copyright

* Copyright (c) 2014- OKUNO Akihiro
* License
    * Apache License, version 2.0
