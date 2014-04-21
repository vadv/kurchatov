require 'net/http'
require 'open-uri'
require 'yajl/json_gem'
require 'kurchatov/version'

module Kurchatov
  module Mixin
    module Http

      USER_AGENT = "Kurchatov (Riemann client)".freeze

      # /path/to/file, https://ya.ru, http://a:a@yandex.ru
      def rest_get(url)
        uri = URI(url)
        if uri.userinfo
          open("#{uri.scheme}://#{uri.hostname}:#{uri.port}#{uri.request_uri}",
               :http_basic_authentication => [uri.user, uri.password],
               'User-Agent' => USER_AGENT).read
        else
          open(url, 'User-Agent' => USER_AGENT).read
        end
      end

      # return: body, http_code
      def http_get(url)
        uri = URI(url)
        req = Net::HTTP::Get.new(uri)
        req['User-Agent'] = USER_AGENT
        res = nil
        begin
          Net::HTTP.start(uri.hostname, uri.port) {|http| res = http.request(req)}
        rescue SocketError, Errno::ECONNREFUSED
          return nil, 0
        end
        return res.body, res.code.to_i
      end

    end
  end
end
