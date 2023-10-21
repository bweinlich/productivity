# AutoHotkey Scripts

Prerequisite: Set OpenAI API key in your OPEN_AI_API_KEY environment variable

1. Download and install AutoHotkey: https://www.autohotkey.com/
2. Put the the .ahk files in any directory, e.g. Home
3. Create a shortcut for select-whole-line.ahk and auto-correct.ahk in the startup: WIN + R -> enter shell:startup and copy the shortcut there
4. Double-click on the scripts once (they will be automatically activated at computer startup in the future)

ChatGPT hotkeys:
ALT + Q - Correct (typing) selected text
ALT + C - Open ChatGPT prompt window and insert created text
ALT + T - Transform the selected text with the given prompt
ALT + F - Open Chrome with ChatGPT Client (insert API key there) and create a new chat

Other hotkeys:
ALT + A - Select paragraph

Further instructions
- To enable paragraph selection in Visual Studio Code or Cursor, use the keybindings.json
- To enable paragraph selection in Notepad++, the command SCI_PARAUPEXTEND (Scintilla Commands) must be set to Ctrl + Shift + U in the hotkey settings on a German keyboard
- The current chat client in use is "ChatGPTNext". The settings need to be adjusted before the first use - among other things, the OpenAI API key needs to be entered. If necessary, the screen position of the "New Chat" button also needs to be adjusted to ensure a new chat is always started. See comments in the script for details.