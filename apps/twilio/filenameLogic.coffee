filenameLogic =

	urlForFilename: (filename) ->
		return "/audio/" + filename

	correctAnswerForFilename: (filename) ->
		# filenames have the format "dude-what_he_says"
		# correct answers are 1 for the dude, 2 for Walter, 3 for Donnie
		parts = filename.split "-"
		characterName = parts[0]
		switch characterName
			when "dude" 	then return "1"
			when "walter" then return "2"
			when "donnie" then return "3"
			else return "0"

	randomFilename: (files) -> 
		# Remove any files named ".DS_Store" from the array
		# It screws up our plan to choose a random wav file
		# Bless your 6-colored heart, apple
		dsStoreIndex = files.indexOf ".DS_Store"
		files.splice dsStoreIndex, 1 unless dsStoreIndex is -1

		# Now we can return a random element from the array
		index = Math.floor(Math.random() * files.length)
		return files[index]

module.exports = filenameLogic