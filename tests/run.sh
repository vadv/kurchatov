#!/bin/sh -e


bundle exec ruby ./tests/server.rb &

rm -rf ./tmp
mkdir -p ./tmp
cat > tmp/config.yml <<EOF
not_exists:
  - not error please
test2:
  url: './tests/run.sh'
  cmd: 'ls'
  parent: 'test'
  counter: 2
test:
  - url: 'http://google.com'
    cmd: 'test -f ./tests/run.sh'
  - url: 'https://www.kernel.org'
    cmd: 'ps'
EOF

cat > tmp/test1.rb <<EOF
interval 10
name "test"

default[:url] = 'http://notexists'
default[:cmd] = 'ls /notexists'

collect do
  @counter ||= 0
  Log.info "file command #{plugin.cmd} return: #{shell(plugin.cmd)}"
  Log.info "get size from #{plugin.url}: #{rest_get(plugin.url).size}"
  @counter += 1
  exit 0 if plugin.counter && @counter > plugin.counter.to_i
  event(:metric => 3, :critical => 2, :warning => 1)
  event(:metric => 2, :critical => 2, :warning => 1)
  event(:metric => 1, :critical => 2, :warning => 1)
  event(:metric => 0, :critical => 2, :warning => 1)
end
EOF

# --test-plugin
bundle exec ./bin/kurchatov --test-plugin ./tmp/test1.rb --logfile ./tmp/testplugin.log -l debug || echo "Mock error in 'ls /notexists'" 
echo "Stdout --test-plugin:"
cat ./tmp/testplugin.log
grep -q 'STDERR: ls: cannot access /notexists' ./tmp/testplugin.log

# load config and helpers 
bundle exec ./bin/kurchatov -d ./tmp/ -c ./tmp/config.yml --hosts 127.0.0.1 -l debug --stop-on-error --logfile ./tmp/loadplugins.log
echo "Stdout loader"
cat ./tmp/loadplugins.log
grep  'Start plugins' ./tmp/loadplugins.log | grep -q '@name="test_0"'
grep  'Start plugins:' ./tmp/loadplugins.log | grep -q '@name="test_1"'
grep  'Start plugins:' ./tmp/loadplugins.log | grep -q '@name="test2"'
grep 'file command ls return: Gemfile' ./tmp/loadplugins.log
grep 'get size from http://google.com:' ./tmp/loadplugins.log
grep 'get size from https://www.kernel.org' ./tmp/loadplugins.log
grep 'get size from ./tests/run.sh' ./tmp/loadplugins.log
