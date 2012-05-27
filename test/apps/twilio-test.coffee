require '../_helper'
app						= require "../../server"
assert				= require 'assert'
request				= require 'request'
filenameLogic = require '../../apps/twilio/filenameLogic'

# the filenameLogic library  
# 	* formats the filename as a URL for use in Twiml
#		* returns the correct answer number for a filename
#		* relies on the filenames to be formatted as character-what_he_says.wav
describe 'filenameLogic', ->

	it "returns the correct url for the filename", ->
		filename = "character-what_he_says.wav"
		assert.equal filenameLogic.urlForFilename(filename), "/audio/" + filename

	it "returns the correct answer for the filename", ->
		dudeFilename = "dude-what_he_says.wav"
		walterFilename = "walter-what_he_says.wav"
		donnieFilename = "donnie-what_he_says.wav"
		assert.equal filenameLogic.correctAnswerForFilename(dudeFilename), "1"
		assert.equal filenameLogic.correctAnswerForFilename(walterFilename), "2"
		assert.equal filenameLogic.correctAnswerForFilename(donnieFilename), "3"

# the twilio namespace holds our web service methods called by the Twilio servers
# and returns the appropriate Twiml to drive the IVR quiz
describe 'twilio', ->
	# Store the body of the response for general use in all the tests
	_body = null

	# postWelcome is a utility method that posts to the welcome url and captures the response twiml as _body
	postWelcome = (callback) ->
		request.post {uri:"http://localhost:#{app.settings.port}/twilio/welcome"}, (err, response, body) ->
			assert.ifError err
			_body = body
			callback()				


	describe 'Start of Quiz: POST /twilio/welcome', ->

		# Excercise the welcome URL and capture the twiml before each test
		before (done) ->
			postWelcome done

		it "has a <Response> root tag", ->
			assert.hasXmlTag _body, '/Response'

		it "says 'Welcome to the Big Lebowski Quiz'", ->
			assert.hasXmlTagMatch _body, '//Say', /Welcome to the Big Lebowski Quiz/

		it "asks to press 1 for the Dude, 2 for Walter, and 3 for Donnie", ->
			assert.hasXmlTagMatch _body, '//Say[2]', /Press 1.*the Dude/g
			assert.hasXmlTagMatch _body, '//Say[3]', /Press 2.*Walter/g
			assert.hasXmlTagMatch _body, '//Say[4]', /Press 3.*Donnie/g

		it "gathers digits", ->
			assert.hasXmlTag _body, "//Gather[@action='guess' and @numDigits='1']"

		# Make sure we have a Play verb and that it provides a URL with appropriate path and filename
		it "plays the clip to guess", ->
			assert.hasXmlTagMatch _body, "//Gather/Play", /audio\/(dude|walter|donnie)-.*.wav/g

	describe 'Guessing an answer: POST /twilio/guess', ->

		# Utility method to post to the guess URL with specified guess and capture the twiml as _body
		postGuess = (guess, callback) ->
			options =
				uri:"http://localhost:#{app.settings.port}/twilio/guess"
				form:
					Digits: guess

			request.post options, (err, response, body) ->
				assert.ifError err
				_body = body
				callback()

		describe 'guessed correctly', ->

			# Utility method to parse the body and return the correct guess number.
			correctGuessFromBody = (body) ->
				# The body is composed of Twiml XML.  Parse it and extract the Gather/Play tag's text
				#  which is the URL to the wav file.
				libxmljs = require 'libxmljs'
				doc = libxmljs.parseXmlString body
				element = doc.find("//Gather/Play")

				# We expect to the the audio url as the text of the 0th element found
				audioUrl = element[0].text()

				# extract the filename part of the URL and use the filenameLogic library to 
				# compute the correct answer
				# the RegEx returns an array of matches, the 0th is the filename
				filename = /(dude|walter|donnie)-.*wav/.exec(audioUrl)[0]
				#console.log "Filename: #{filename}"
				correctAnswer = filenameLogic.correctAnswerForFilename(filename)
				#console.log "Correct Answer: #{correctAnswer}"
				return correctAnswer

			# Post a correct guess before each test by parsing it out of the welcome post
			before (done) ->
				postWelcome () ->
					postGuess correctGuessFromBody(_body), done

			it "should say 'Far out!'", ->
				assert.hasXmlTagMatch _body, '//Say', /Far out/

			it "should ask to play again", ->
				assert.hasXmlTagMatch _body, '//Say[2]', /Press 1 to play again/
				assert.hasXmlTag _body, "//Gather[@action='welcome' and @numDigits='1']"

		describe 'guessed incorrectly', ->

			# Post an incorrect guess before each test
			before (done) ->
				postWelcome () ->
					# 0 is never a correct answer
					postGuess("0", done)

			it "should say 'Bummer!'", ->
				assert.hasXmlTagMatch _body, '//Say', /Bummer/


