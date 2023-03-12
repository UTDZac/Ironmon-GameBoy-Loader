---@diagnostic disable: undefined-global
GameBoyLoader = {}

function GameBoyLoader.init()
	-- Quickload button combo to create a new ROM
	GameBoyLoader.buttonCombo =			"A, B, Start"

	-- Are you using a patched ROM with pseudo-fluctuating exp curve? 'true' for Yes, 'false' for No
	GameBoyLoader.fluctuatingCurve =	true

	-- Loader files
	GameBoyLoader.romName =				"Rom.gb"
	GameBoyLoader.randomizerJar =		"PokeRandoZX.jar"
	GameBoyLoader.settingsFile =		"RBY_Kaizo.rnqs"
	GameBoyLoader.settingsFileCurve =	"RBY_SlowExpCurve.rnqs"
	GameBoyLoader.randomizedRomName =	"RBY Rom AutoRandomized.gbc"

	-- Other stuff
	GameBoyLoader.version = "1.1"
	GameBoyLoader.slash = package.config:sub(1,1) or "\\" -- Windows is \ and Linux is /
	GameBoyLoader.dir = ""
	GameBoyLoader.folder = "" -- Currently unused
	GameBoyLoader.shouldLoadNextSeed = false
	GameBoyLoader.prevJoypadInput = {}

	GameBoyLoader.setupWorkingDirectory()
end

function GameBoyLoader.run()
	collectgarbage()
	console.clear()
	print(string.format("Ironmon GameBoy Loader v%s now running.", GameBoyLoader.version))
	print(string.format("Randomize a new seed with: %s", GameBoyLoader.buttonCombo))

	while GameBoyLoader.shouldLoadNextSeed == false do
		GameBoyLoader.mainInputLoop()
		emu.frameadvance()
	end
	GameBoyLoader.loadNextRom()
	GameBoyLoader.run()
end

function GameBoyLoader.mainInputLoop()
	local joypadButtons = joypad.get()

	if not GameBoyLoader.shouldLoadNextSeed then
		local allPressed = true
		for button in string.gmatch(GameBoyLoader.buttonCombo, '([^,%s]+)') do
			if joypadButtons[button] ~= true then
				allPressed = false
				break
			end
		end
		GameBoyLoader.shouldLoadNextSeed = allPressed
	end

	GameBoyLoader.prevJoypadInput = joypadButtons
end

function GameBoyLoader.loadNextRom()
	GameBoyLoader.shouldLoadNextSeed = false

	-- Disable Sound
	local wasSoundOn = client.GetSoundOn()
	client.SetSoundOn(false)

	if GameBoyLoader.generateNewRom() then
		client.closerom()
		client.openrom(GameBoyLoader.getDir() .. GameBoyLoader.randomizedRomName)
	else
		print("> [ERROR] The Randomizer program failed to generate a ROM.")
	end

	-- Enabled Sound
	if client.GetSoundOn() ~= wasSoundOn and wasSoundOn ~= nil then
		client.SetSoundOn(wasSoundOn)
	end
end

function GameBoyLoader.generateNewRom()
	local workingDir = GameBoyLoader.getDir()
	local errorLogName = "RandomizerErrorLog.txt"
	local errorMessage = "> [ERROR] The Randomizer program failed to generate a ROM."

	local javaCommand1 = string.format(
		'java -Xmx4608M -jar "%s" cli -s "%s" -i "%s" -o "%s" -l',
		workingDir .. GameBoyLoader.randomizerJar,
		workingDir .. GameBoyLoader.settingsFile,
		workingDir .. GameBoyLoader.romName,
		workingDir .. GameBoyLoader.randomizedRomName
	)

	local javaCommand2

	if GameBoyLoader.fluctuatingCurve then
		javaCommand2 = javaCommand1
		javaCommand1 = 'echo Fluctuating curve detected.' -- Display this first
	else
		javaCommand2 = string.format(
			'java -Xmx4608M -jar "%s" cli -s "%s" -i "%s" -o "%s"',
			workingDir .. GameBoyLoader.randomizerJar,
			workingDir .. GameBoyLoader.settingsFileCurve,
			workingDir .. GameBoyLoader.randomizedRomName,
			workingDir .. GameBoyLoader.randomizedRomName
		)
	end

	local batchCommands = {
		'echo Randomizing a new ROM...',
		javaCommand1,
		javaCommand2,
		'echo Randomization complete.'
	}
	local errorMsgCommand = string.format('echo && echo %s', errorMessage)

	local combinedCommand = string.format("(%s) || (%s)", table.concat(batchCommands, ' && '), errorMsgCommand)
	local success = GameBoyLoader.tryOsExecute(combinedCommand, GameBoyLoader.folder .. errorLogName)

	return success
end

function GameBoyLoader.tryOsExecute(command, errorFile)
	local tempOutputFile = GameBoyLoader.folder .. "temp_output.txt"
	local commandWithOutput = string.format('%s >"%s"', command, tempOutputFile)
	if errorFile ~= nil then
		commandWithOutput = string.format('%s 2>"%s"', commandWithOutput, errorFile)
	end
	local result = os.execute(commandWithOutput)
	local success = (result == true or result == 0) -- 0 = success in some cases
	if not success then
		return success, {}
	end
	return success, GameBoyLoader.readLinesFromFile(tempOutputFile)
end

function GameBoyLoader.getDir()
	return GameBoyLoader.dir .. GameBoyLoader.folder
end

function GameBoyLoader.setupWorkingDirectory()
	local getDirCommand
	if GameBoyLoader.slash == "\\" then
		getDirCommand = "cd" -- Windows
	else
		getDirCommand = "pwd" -- Linux
	end

	local success, fileLines = GameBoyLoader.tryOsExecute(getDirCommand)
	if success then
		if #fileLines >= 1 then
			GameBoyLoader.dir = fileLines[1]
		end
	end

	GameBoyLoader.dir = GameBoyLoader.formatPathForOS(GameBoyLoader.dir)
	if GameBoyLoader.dir:sub(-1) ~= GameBoyLoader.slash then
		GameBoyLoader.dir = GameBoyLoader.dir .. GameBoyLoader.slash
	end
end

function GameBoyLoader.readLinesFromFile(filename)
	local lines = {}

	local filepath = GameBoyLoader.getPathIfExists(filename)
	if filepath == nil then
		return lines
	end

	local file = io.open(filepath, "r")
	if file == nil then
		return lines
	end

	local fileContents = file:read("*a")
	if fileContents ~= nil and fileContents ~= "" then
		for line in fileContents:gmatch("([^\r\n]+)[\r\n]*") do
			if line ~= nil then
				table.insert(lines, line)
			end
		end
	end
	file:close()

	return lines
end

function GameBoyLoader.getPathIfExists(filepath)
	if filepath == nil or filepath == "" then return nil end

	local file = io.open(filepath, "r")
	if file ~= nil then
		io.close(file)
		return filepath
	end

	filepath = GameBoyLoader.dir .. filepath
	file = io.open(filepath, "r")
	if file ~= nil then
		io.close(file)
		return filepath
	end

	return nil
end

function GameBoyLoader.formatPathForOS(path)
	path = path or ""
	if GameBoyLoader.slash == "/" then
		path = path:gsub("\\", "/")
	else
		path = path:gsub("/", "\\")
	end
	return path
end

GameBoyLoader.init()
GameBoyLoader.run()
