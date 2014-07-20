require 'test/unit'
require 'fluent/log'
require 'fluent/test'

$log = Fluent::Log.new(Fluent::Test::DummyLogDevice.new, Fluent::Log::LEVEL_WARN)

def records
  [
    {
      "remote_addr" => "114.170.6.118",
      "remote_user" => "-",
      "time_local" => "20/Jul/2014:18:25:50 +0000",
      "request" => "GET /foo HTTP/1.1",
      "status" => "200",
      "body_bytes_sent" => "911",
      "http_referer" => "-",
      "http_user_agent" => "Mozilla/5.0 (Linux; U; Android 4.2.2; ja-jp; SO-04E Build/10.3.1.B.0.256) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
      "request_time" => "0.058",
      "upstream_addr" => "192.168.222.180:80",
      "upstream_response_time" => "0.058"
    },
    {
      "remote_addr" => "180.214.48.86",
      "remote_user" => "-",
      "time_local" => "20/Jul/2014:18:25:50 +0000",
      "request" => "POST /bar HTTP/1.1",
      "status" => "200",
      "body_bytes_sent" => "57",
      "http_referer" => "-",
      "http_user_agent" => "Mozilla/5.0 (Linux; U; Android 4.2.2; ja-jp; SO-04E Build/10.3.1.B.0.256) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
      "request_time" => "0.041",
      "upstream_addr" => "10.0.0.143:80",
      "upstream_response_time" => "0.041"
    },
    {
      "remote_addr" => "153.160.159.80",
      "remote_user" => "-",
      "time_local" => "20/Jul/2014:18:25:50 +0000",
      "request" => "GET /foo HTTP/1.1",
      "status" => "200",
      "body_bytes_sent" => "34139",
      "http_referer" => "/bar",
      "http_user_agent" => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:30.0) Gecko/20100101 Firefox/30.0",
      "request_time" => "0.000",
      "upstream_addr" => "-",
      "upstream_response_time" => "-"
    },
    {
      "remote_addr" => "172.56.33.226",
      "remote_user" => "-",
      "time_local" => "20/Jul/2014:18:25:50 +0000",
      "request" => "GET /foo HTTP/1.1",
      "status" => "200",
      "body_bytes_sent" => "791",
      "http_referer" => "-",
      "http_user_agent" => "en;Mozilla/5.0 (Linux; U; Android 4.3; en-us; SGH-T999 Build/JSS15J) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
      "request_time" => "0.073",
      "upstream_addr" => "192.168.222.209:80",
      "upstream_response_time" => "0.073"
    }
  ]
end
