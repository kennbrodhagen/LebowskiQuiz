# http://demo.twilio.com/welcome/voice
filenameLogic = require('./filenameLogic')
fs = require('fs')

routes = (app) ->
	app.namespace '/twilio', ->
			app.post '/welcome', (req, res, next) ->
				fs.readdir "#{__dirname}/../../public/audio", (err, files) ->
					if err
						console.log "Error #{JSON.stringify(err)}"
						next err
					else
						randomFilename = filenameLogic.randomFilename files
						correctAnswer = filenameLogic.correctAnswerForFilename randomFilename
						audioFile = filenameLogic.urlForFilename randomFilename
						console.log "/twilio/welcome: Filename:'#{randomFilename}' Answer: '#{correctAnswer}' URL: '#{audioFile}'"
						req.session.correctAnswer = correctAnswer
						req.session.save
						res.render "#{__dirname}/views/welcome", audioFile: audioFile

			app.post '/guess', (req, res) ->
				guess = req.body.Digits
				correctAnswer = req.session.correctAnswer
				console.log "/twilio/guess: Correct Answer: '#{correctAnswer}' Guess: '#{guess}'"
				responseText = null

				if guess is correctAnswer
					responseText = "Far out! You got it right."
				else
					responseText = "Bummer!  You got it wrong."

				res.render "#{__dirname}/views/guess", responseText: responseText

module.exports = routes