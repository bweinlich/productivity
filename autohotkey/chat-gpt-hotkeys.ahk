#Requires AutoHotkey v2.0
#Include JSON.ahk

; PREREQUISITE: Store your OpenAI-API-Key to the env variable OPEN_AI_API_KEY

!f:: ; This script is triggered by ALT + F
{
	Run "chrome.exe https://chat-gpt-next-web.vercel.app/"
	Sleep 1000
	MouseClick("left", 595, 950) ; Click on "New Chat" button in the bottom right corner
	; Screen coordinates of button position may need adjustment according
	; to your Chrome settings. Use https://amourspirit.github.io/AutoHotkey-Snippit/WindowSpy.html
	; for finding out the screen coordinates of the button by hovering over it while having
	; the window spy tool open
	Exit
}


; ### Copy text to the clipboard, correct it by sending it to ChatGPT and paste it back ###
!q:: ; This script is triggered by ALT + Q
{	
	apiKey := EnvGet("OPEN_AI_API_KEY")
	CheckOpenAiApiKeyPresent(apiKey)
	
    ClipSave := ClipboardAll() ; store current clipboard
    A_Clipboard := "" ; clear the clipboard
    Send "^c" ; copy selected text
    if ClipWait(1) ; wait up to a second for content
    {	
		; ChatGPT request
		textToBeCorrected := EncodeSpecialChars(A_Clipboard)
		body := '{"model": "gpt-4", "messages": [{"role": "user", "content": "Kannst du aus folgendem '
			. 'Text die Rechtschreib- und Grammatikfehler entfernen? Tausche dabei keine Wörter aus, ändere '
			. 'keine Formulierungen, behalte Zeilenumbrüche bei und gib dein Ergebnis ohne Anführungszeichen '
			. 'vorne und hinten zurück: ' textToBeCorrected '"}], "temperature": 0}'
		response := sendRequestToChatGpt(body, apiKey)
		A_Clipboard := response.choices[1].message.content ; Extract from response JSON
		
        Send "^v" ; paste
        Sleep 500 ; wait for Windows to complete paste
    }
    A_Clipboard := ClipSave ; restore old clipboard content
    ClipSave := "" ; clear variable
	Exit
}

; ### Copy text to the clipboard, transform it with a prompt for ChatGPT and paste it back ###
!t:: ; This script is triggered by ALT + T
{	
	apiKey := EnvGet("OPEN_AI_API_KEY")
	CheckOpenAiApiKeyPresent(apiKey)
	
    ClipSave := ClipboardAll() ; store current clipboard
    A_Clipboard := "" ; clear the clipboard
    Send "^c" ; copy selected text
    if ClipWait(1) ; wait up to a second for content
    {	
		textToBeTransformed := EncodeSpecialChars(A_Clipboard)
		
		; Get transformation request from popup
		transformationIB := InputBox("Please enter prompt for ChatGPT!", "Input prompt", "w1000 h100")
		if (transformationIB.Result = "Cancel" || transformationIB.Value = "") {
			A_Clipboard := ClipSave ; restore old clipboard content
			Exit
		}
		transformationPrompt := EncodeSpecialChars(transformationIB.Value)
		
		; ChatGPT request
		body := '{"model": "gpt-4", "messages": [{"role": "user", "content": "Bitte wende folgende Transformation \"' 
			. transformationPrompt '\" auf diesen Text an: ' textToBeTransformed '"}], "temperature": 0}'
		response := sendRequestToChatGpt(body, apiKey)
		A_Clipboard := response.choices[1].message.content ; Extract from response JSON
		
        Send "^v" ; paste
        Sleep 500 ; wait for Windows to complete paste
    }
    A_Clipboard := ClipSave ; restore old clipboard content
    ClipSave := "" ; clear variable
	Exit
}

; ### Create new text with ChatGPT and paste it ###
!c:: ; This script is triggered by ALT + C
{	
	apiKey := EnvGet("OPEN_AI_API_KEY")
	CheckOpenAiApiKeyPresent(apiKey)
	ClipSave := ClipboardAll() ; store current clipboard
	
	; Get creation request from popup
	creationTextInput := Gui(, "Input prompt")
	creationTextInput.Add("Text",, "Please enter prompt for ChatGPT!")
	creationTextInput.Add("Edit", "vPrompt w1000 h100")
	creationTextInput.Add("Button", "default", "OK").OnEvent("Click", ProcessUserInput)
	creationTextInput.Show
	ProcessUserInput(*)
	{
		Saved := creationTextInput.Submit()  ; Save the contents of named controls into an object.
		creationPrompt := EncodeSpecialChars(Saved.Prompt)
	
		; ChatGPT request
		body := '{"model": "gpt-4", "messages": [{"role": "user", "content": "' creationPrompt '"}], "temperature": 0}'
		response := sendRequestToChatGpt(body, apiKey)
		A_Clipboard := response.choices[1].message.content ; Extract from response JSON
			
		Send "^v" ; paste
		Sleep 500 ; wait for Windows to complete paste
		Exit
	}
}

CheckOpenAiApiKeyPresent(apiKey)
{
	if (apiKey = "") {
		MsgBox "Please store your OpenAI-API-Key into the environment variable OPEN_AI_API_KEY to use this script"
		Exit
	}
}

EncodeSpecialChars(s)
{
	returnValue := StrReplace(s, '"', '\"') ; Encode double quotes
	returnValue := StrReplace(returnValue, '`r`n', '\n') ; Encode line breaks (Windows)
	returnValue := StrReplace(returnValue, '`n', '\n') ; Encode line breaks (Linux)
	return returnValue
}

sendRequestToChatGpt(body, apiKey)
{
	; Send request
	url := "https://api.openai.com/v1/chat/completions"	
	whr := ComObject("WinHttp.WinHttpRequest.5.1")
	whr.Open("POST", url, true)
	whr.SetRequestHeader("Content-Type", "application/json")
	whr.SetRequestHeader("Authorization", "Bearer " apiKey)
	whr.Send(body)
	whr.WaitForResponse()
			
	; Convert response to UTF-8
	arr := Whr.responseBody
	pData := NumGet(ComObjValue(arr) + 8 + A_PtrSize, "Int64")
	length := arr.MaxIndex() + 1
	responseText := StrGet(pData, length, "utf-8")
			
	; Return parsed response
	return JSON.parse(responseText, false, false)
}