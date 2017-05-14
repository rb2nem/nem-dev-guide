#!/usr/local/bin/node
global.nem = require('nem-sdk').default
global.sockjs = require('sockjs-client').default
global.stomp = require('stompjs').default
global.repl = require('repl').start()
