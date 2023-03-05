## Ironmon-GameBoy-Loader
A simple script to automatically randomize Ironmon game ROMs for Gen 1 Pokémon games.

#### Compatibility Notes and Requirements
- You will need [Java 64-bit Offline](https://www.java.com/en/download/manual.jsp) to use this script
- This script is only compatible with [Bizhawk 2.8](https://github.com/TASEmulators/BizHawk/releases/tag/2.8) emulator
- This script uses the [official Ironmon randomizer settings](https://gist.github.com/UTDZac/a147c497424dfbd537d8c4b0c22b5621#red--blue--yellow) for [v4.6.0 of the Randomizer ZX program](https://github.com/Ajarmar/universal-pokemon-randomizer-zx/releases/tag/v4.6.0)

## Download
1) Download the [latest release](https://github.com/UTDZac/Ironmon-GameBoy-Loader/releases/latest) from the GitHub's Releases page
2) Extract the contents of the `.zip` file into a new folder
   - The following instructions will call this folder **"Ironmon GameBoy Loader"**

## Install and Setup
1) Place a copy of your Gen 1 Pokémon game ROM into the "Ironmon GameBoy Loader" folder
2) Rename your ROM to exactly `Rom.gb`, so the script can find it

Example of what your folder should look like:

   > ![image](https://user-images.githubusercontent.com/4258818/222988428-ec828464-dcbc-4ca1-985e-33dc206a2f83.png)

## How to Use
1) Open Bizhawk
2) Open any Gen 1 Pokémon game
   - Note: This is only temporary, as the Ironmon Gameboy Loader will create a new rom for you.
3) In Bizhawk, open the **"Lua Console"** which is under the **"Tools"** menu
4) Load the **"GameBoyLoader.lua"** script file from the "Ironmon GameBoy Loader" folder
5) You're all set and ready to go!

Now that the script is loaded, you can create a new randomized Ironmon game rom by pressing **A + B + Start** all at once on your controller. This is similar to the Quickload feature of the Ironmon Tracker used for Gen 3-5 games.

If you want to save your game and come back to it later, be sure to use a save-state. The game ROM you want to load to continue playing will be the `RBY Rom AutoRandomized.gbc` file found in the "Ironmon GameBoy Loader" folder.

## Configuration
As this script is fairly lightweight, if you want to change something about it then you'll have to edit the script file `GameBoyLoader.lua` itself. You can do so with any text editor program such as Notepad.

For example, you can change the button combo to create a new randomized from by changing the following line of code:
```lua
GameBoyLoader.buttonCombo = "A, B, Start"
-- ... changed to ...
GameBoyLoader.buttonCombo = "A, B, L, R"
```

Or you can change the Ironmon challenge difficulty from Kaizo to Survival:
```lua
GameBoyLoader.settingsFile = "RBY_Kaizo.rnqs"
-- ... changed to ...
GameBoyLoader.settingsFile = "RBY_Survival.rnqs"
```
