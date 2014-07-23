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
  statsite_flush_interval 1s
  flush_interval 1s
</match>
```

then you will get events such as below every specified seconds.

```json
statsite 1406124737 {"type":"counts","key":"status_500","value":1.0}
statsite 1406124737 {"type":"counts","key":"status_200","value":3.0}
statsite 1406124737 {"type":"counts","key":"status_302","value":1.0}
statsite 1406124737 {"type":"timers","key":"request_time","value":12.0,"statistic":"sum"}
statsite 1406124737 {"type":"timers","key":"request_time","value":40.0,"statistic":"sum_sq"}
statsite 1406124737 {"type":"timers","key":"request_time","value":2.4,"statistic":"mean"}
statsite 1406124737 {"type":"timers","key":"request_time","value":1.0,"statistic":"lower"}
statsite 1406124737 {"type":"timers","key":"request_time","value":5.0,"statistic":"upper"}
statsite 1406124737 {"type":"timers","key":"request_time","value":5,"statistic":"count"}
statsite 1406124737 {"type":"timers","key":"request_time","value":1.67332,"statistic":"stdev"}
statsite 1406124737 {"type":"timers","key":"request_time","value":2.0,"statistic":"median"}
statsite 1406124737 {"type":"timers","key":"request_time","value":5.0,"statistic":"p95"}
statsite 1406124737 {"type":"timers","key":"request_time","value":5.0,"statistic":"p99"}
statsite 1406124737 {"type":"timers","key":"request_time","value":12.0,"statistic":"rate"}
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

### Parameter

key                     | type   | description                                                                                | required | default
---                     | ---    | ---                                                                                        | ---      | ---
tag                     | string | The tag of output events.                                                                  | yes      |
metrics                 | array  | How to retrive statsite messages from fluentd event. see the details below.                | yes      |
histograms              | array  | THe statstie histogram settings. see the details below.                                    | no       | []
statiste_path           | string | The path of statsite command. Leave this blank if statsite places under $PATH.             | yes      | statsite
statsite_flush_interval | time   | The interval at which statsite flush aggregated results.                                   | no       | 10s
time_eps                | float  | The upper bound on error for timer estimates. Please refer to statsite official page.      | no       | 0.01
set_eps                 | float  | The upper bound on error for unique set estimates. Please refer to statsite official page. | no       | 0.02
child_respawn           | string | How many times statsite will be respawned in case of unexpected exit.                      | no       |

### Metrics

Metrics parameter specifies how to form messages to send to statsite from each fluentd event.

Top level of **metrics* parameter must be an array which contains strings or hashes. If you set multliple elements in an array, equivalent number of messages will be sent to statsite for one fluentd event.

For example, given this metrics setting,

```
metrics [
    {"key": "key_1", "value": "1", "type": "s"}
    {"key": "key_2", "value": "1", "type": "s"}
]
```

and this fluentd event is comming,

```
{"foo": "f", "bar": "b", "hoge": "h"}
```

then the events below will be sent to statsite

```
key_1:1|c
key_2:1|c
```

Every element of the array must foloow the one of these format, the string format, and the hash format. Both they have the same fields semantically. See the details of these formats below.

#### Fields

key        | type   | description            | required
---        | ---    | ---                    | ---
key        | string | message key            | yes
value_time | string | message value          | yes
type       | enum   | statsite message type. | yes

With these settings, A message sent to statsite is "${key}:${value}|${type}\n"

You should also see [Statsite official page](http://armon.github.io/statsite/) to see the statsite supports in detail.

#### String format

String format almost the same as Statsite's event protocol, though this format supports variable substitution in key and value field, which is described in detail below.

##### Example

```
metrics [
    "status_${status}:1|c"
]
```

#### Hash format

Hash format is expressed as JSON Object.

##### Example

```json
metrics [
    {"key": "status_${status}", "value": "1", "type": "c"}
]
```

#### Message Type

Please refer to [Statsite official page](http://armon.github.io/statsite/).

type | description
---  | ---
kv   | Simple Key/Value.
g    | Gauge, similar to kv but only the last value per key is retained
ms   | Timer.
h    | Alias for timer
c    | Counter.
s    | Unique Set

#### Variable substitution

Both in string and hash format, key and value field support substitution of variable.

When the string "${*subst_key*}" exists key or value field, this will be replaces with the corresponding value in the fluentd event.

For example, given this metrics setting,

```
metrics [
    {"key": "key_${foo}_${bar}", "value": "${hoge}", "type": "c"}
]
```

and this fluentd event is comming,

```
{"foo": "f", "bar": "b", "hoge": "1"}
```

then the events below will be sent to statsite

```
key_f_b:1|s
```

When any one of the substitution key does not exists in the fluentd event, no messages will be sent to statsite for that metric element.

For example, given this metrics setting,

```
metrics [
    {"key": "key_${foo}", "value": "1", "type": "c"},
    {"key": "key_${bar}", "value": "1", "type": "c"}
]
```

and this fluentd event is comming,

```
{"foo": "f"}

then the events below will be sent to statsite

```
key_f:1|c
```

### Histograms

#### Example

```json
histogram [
    {"prefix": "request_time", "min": 0, "max": 1, "width": 0.1}
]
```

#### Fields

key    | type   | description                                                                        | required
---    | ---    | ---                                                                                | ---
prefix | string | This is the key prefix to match on. This is also used as a suffix of section name. | no
min    | float  | The minimum bound on the histogram.                                                | yes
max    | float  | The maximum bound on the histogram.                                                | yes
width  | float  | The width of each bucket between the min and max.                                  | yes

## Copyright

* Copyright (c) 2014- OKUNO Akihiro
* License
    * Apache License, version 2.0
