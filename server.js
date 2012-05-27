require('coffee-script');

/**
 * Module dependencies.
 */

var express = require('express');
require('express-namespace')

var app = module.exports = express.createServer();
var port = process.env.PORT || 3000;

// Configuration
app.configure(function () {
	//app.use(express.logger('default'));
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.set('port', port);
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.static(__dirname + '/public'));
  app.use(express.cookieParser());
  app.use(express.session({
    secret: "Log Jammin'"
  }));
  app.use(require('connect-assets')());
  app.use(app.router);
});

app.configure('development', function () {
	//app.use(express.logger('dev'));
  app.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
});

app.configure('test', function () {
  app.set('port', port + 1);
});

app.configure('production', function () {
  app.use(express.errorHandler());
});

// Routes
require('./apps/twilio/routes')(app);

app.listen(app.settings.port);
console.log("Express server listening on port %d in %s mode", app.settings.port, app.settings.env);
