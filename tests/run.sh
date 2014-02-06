#!/bin/sh -e
bundle exec ruby ./tests/server.rb &
bundle exec kurchatov -c ./tests/data/config.yml -d ./tests/data -H 127.0.0.1 --stop-on-error --http 127.0.0.1:55755
