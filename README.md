The Big Lebowski Quiz
=====================

This project is a [Twilio][1] based quiz game about [the Big Lebowski][2].  Twilio is a cloud-based communications service that provide a phone number that users dial into and interact with a voice menu system.  The Big Lebowski Quiz is a [nodejs][3] web app that renders XML documents which Twilio parses and tells it what voice prompts to play and how to respond to numbers entered by the user.  Twilio has it's own domain-specific dialect of XML called [TwiML][4], so the The Big Lebowski Quiz renders TwiML as its output instead of the usual HTML. 

Project Organization
--------------------
LebowskiQuiz is a node js app organized in a file structure I learned on the [PeepCode Full Stack Node.js tutorial][7]

Here are the key folders/files:

* apps
This is a top-level folder for holding "mini-apps".  The idea is each mini-app is almost stand-alone so you can easily share code with other web app projcects for things like login, etc.  In the case of LebowskiQuiz there is just one app called "twilio" which renders TwiML for Twilio to consume.  Under each app directory is a "views" directory which holds the .jade files used by the [Jade Templating Engine][8].

* bin
This folder basically holds some utility bash scripts to kick off some common processes I used in development.  

* public
Public is where all the static files are.  There's some code in server.js to opitimize the delivery of them.  The only static files in LebowskiQuiz are the audio files used for the app.

* test
Big surprise, tests go here.  There's a couple of helper scripts and then an apps directory which has one CoffeeScript file for each mini-app (in this case just the "twilio" mini-app).

* Procfile
See Deployment below.  This is used by Heroku.

* package.json
This file tells our package manager which depenendices are needed for the project. 

* server.js
This is the "main" file for kicking up the server.


Deployment
----------
LebowskiQuiz is deployed onto [Heroku][5].  There are a few elements that are necessary to make this work:

*  Procfile
This is a file used by the Foreman harness that Heroku uses.  It essentially provides the command line for Heroku to start the node app.  In this case it simply kicks up the server.js file.

*  engines reference in package.json
Heroku needs to know which versions of node and npm to use to run your app.  The first time I tried to deploy Heroku guessed for me and it failed.  I wasn't really sure which versions I was using so I did a couple of quick node --verion and npm --version commands and then then added the engines element in package.json.  Note that npm also lets you specify a scalar element called "engine" in package.json but this did not work for me on Heroku.  

* Setting it up in Heroku
Other than the trick above with using engines vs engine in package.json I was successful just following the [Heroku instructions for setting up node js][6].

[1]: http://www.twilio.com/
[2]: http://www.imdb.com/title/tt0118715/
[3]: http://nodejs.org/
[4]: http://www.twilio.com/docs/api/twiml
[5]: http://www.heroku.com/
[6]: https://devcenter.heroku.com/articles/nodejs
[7]: https://peepcode.com/products/full-stack-nodejs-i
[8]: http://jade-lang.com/
