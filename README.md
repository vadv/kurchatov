[![Build Status](https://travis-ci.org/vadv/kurchatov.png)](https://travis-ci.org/vadv/kurchatov)

# Kurchatov

Перед вами гем для мониторинга с помощью [riemann](http://riemann.io).
Я люблю [chef](http://www.getchef.com) и [ohai](http://docs.opscode.com/ohai.html),
поэтому здесь есть немного первого и немного второго.

Юзкейз таков: 
 * Kurchatov попадает в среду (окружение, приложения) которую не знает, и изучает ее с помощью ohai
 * Решает какие плагины запускать
 * Отсылает сообщения на riemann-хост со присвоеными статусами


## DSL

Решено использовать dsl для написания плагинов, плагин выглядит так:
```ruby
name "человеко читаемое имя" # по дефолту basename файла
interval 60 # с какой переодичностью будет запускаться плагин
always_start true # плагину не нужны дополнительные настройки

default[:nginx][:file] = "/etc/nginx/nginx.conf"
default[:nginx][:cmd] = "nginx -t" # дефолтные значение для Mashie: 'plugin'
default[:nginx][:url] = "http://127.0.0.1:133233/status" # данные значения смержаться со значениями
                                                         # полученными из конфига

run_if :os => 'linux' do # по умолчанию разрешено запускать все и везде
  File.exists? plugin.file # plugin - не что иное как проставленые значения из default
                           # доступно обращение plugin[:file], plugin["file"], plugin.file
end

collect :web_some_platform => true, :os => 'linux' do # значение полученные через ohai, 
                                                    # collect включиться ohai[:web_some_platform] == true и
                                                    # для ohai[:os] == 'linux'
  metric = rest_get(default[:nginx][:url]).split("\n").first.split("Active connections:").last.to_i
  event(
    :service => "nginx active connections",          # по дефолту name, если редиректим в graphite
    :metric => metric,                               # то service будет ключем для url
    :warning => 10,
    :critical => 20,
    :diff => true, # говорим что запоминать предыдущие значения и если разница между новым и старым
                   # меньше warning - получим статус 'ok', больше critical - 'critical' и так далее
                   # без :diff мы будем считать честные значения
                   # для того чтобы посчитать RPS мы просто делим метрику на interval
    :description => "Что-то для человека-монитора" # допустимо сокращения :desc
  )

  event(
    :service => "nginx test config #{plugin.file}",  # сервис должен быть человекочитаемым но уникальным!
    :state => shell_out("#{ohai[:nginx][:cmd]}").exitstatus == 0  # если :state == true стейт "ok", иначе - "critical"
                                              # shell_out! - сгенерит exception и riemann уйдет сообщение об ошибке
                                              # в плагине, также доступен просто shell() - он вернет только stdout и
                                              # действует как shell_out!
    :desc => "Ой, конфиг не валидный, наверно nginx -t его испортил :("
  )

end

```
Если плагин отправил event, это не означает что он попадает на riemann-server:
* Эвенты группируются и отсылаются асинхронно пачками (все что накопилось за `Kurchatov::Responders::Riemann::FLUSH_INTERVAL` по дефолту 0.5 секунд)
* При отсутвии метрики второй и последующий раз `:state == "ok"` не будет отсылаться

Больше примеров вы найдете [тут](https://github.com/vadv/kurchatov/tree/master/examples).

## OHAI

И в африке ohai. Минимальный пример:
```ruby
provides "postgres"
postgres Mash.new
cmd = "psql -U postgres -tqc 'select version()'"
status, stdout, stderr = run_command(:command => cmd)
postgres[:version] = stdout.strip
```

## Config

Это обычный yml-файл с настройками плагинов, eго удобно генерить chef'ом :)
```yaml
plugin name:
  settins name: 
  - 'bla-bla'
```

Есть небольшая магия, для того чтобы использовать плагин как провайдер (например следить за определенными портами):
```yaml
web watcher:
  - url: http://localhost/ # создастся plugin с name == 'web watcher_0'
    status: 302
  - url: https://localhost/login # новый плагин name == 'web watcher_1'
    status: 200
    ua: Mozilla
robots txt watcher: # новый плагин name == 'robots txt watcher'
  parent: web watcher
  url: https://localhost/robots.txt
  status: 404
  ua: ^Yandex
```

## Почему велосипед

Удобно писать плагины, использовать 1 процесс, 1 коннект, и проч.

Мне не нравиться официальная реализация [riemann-client](https://github.com/aphyr/riemann-ruby-client),
она течет и создает много ненужных *конкретно* для меня полей для протобуфа (но все равно спасибо [aphyr](http://aphyr.com) за
прекрасный сервер :) ), так что вы тут не найдете search и udp.

Упор сделан на потребление памяти (эх, ruby), поэтому все на тредах и на данный момент на 1.9.3 вы можете получить 8Mb RES.

