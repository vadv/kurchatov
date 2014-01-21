#!/bin/sh -e


nc -l 5555 &

rm -rf ./tmp
mkdir -p ./tmp
cat > tmp/config.yml <<EOF
test2:
  url: './tests/run.sh'
  cmd: 'ls'
  parent: 'test'
  counter: 5
test:
  - url: 'http://google.com'
    cmd: 'test -f ./tests/run.sh'
  - url: 'https://www.kernel.org'
    cmd: 'ps'
EOF

cat > tmp/test1.rb <<EOF
interval 10
name "test"

default[:host] = 'http://notexists'
default[:cmd] = 'ls -1 && ls /notexists'

collect do
  @counter ||= 0
  Log.info "file command #{plugin.cmd} return: #{shell(plugin.cmd)}"
  Log.info "get size from #{plugin.url}: #{rest_get(plugin.url).size}"
  @counter += 1
  exit 0 if plugin.counter && @counter > plugin.counter.to_i
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
grep  'Plugins to start' ./tmp/loadplugins.log | grep -q '@name="test_0"'
grep  'Plugins to start' ./tmp/loadplugins.log | grep -q '@name="test_1"'
grep  'Plugins to start' ./tmp/loadplugins.log | grep -q '@name="test2"'
grep 'file command ls return: Gemfile' ./tmp/loadplugins.log
grep 'get size from http://google.com:' ./tmp/loadplugins.log
grep 'get size from https://www.kernel.org' ./tmp/loadplugins.log
grep 'get size from ./tests/run.sh' ./tmp/loadplugins.log

pkill -9 nc || exit 0
