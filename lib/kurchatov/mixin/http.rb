require 'open-uri'
require 'yajl/json_gem'

module Kurchatov
  module Mixin
    module Http

      # /path/to/file, https://ya.ru, http://a:a@yandex.ru
      def rest_get(url)
        uri = URI(url)
        if uri.userinfo
          open("#{uri.scheme}://#{uri.hostname}:#{uri.port}#{uri.request_uri}",
               :http_basic_authentication => [uri.user, uri.password]).read
        else
          open(url).read
        end
      end

    end
  end
end
