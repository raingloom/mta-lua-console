------------
--create GUI
------------
do
	local pw, ph = guiGetScreenSize ()
	local M = math.min ( pw, ph )
	toolbarWidth = 64
	windowHeaderSize = 16
	includeTypeInOutput = true
	serverMode = false
	outputWindow = guiCreateWindow ( 0, 0, 1, 0.5, "output", true )
	inputWindow = guiCreateWindow ( 0, 0.5, 1, 0.5, "input", true )
	outputMemo = guiCreateMemo ( 0, 0, 1, 1, _VERSION, true, outputWindow )
	inputMemo = guiCreateMemo ( 0, 0, 1, 1, "_VERSION", true, inputWindow )
	sendButton = guiCreateButton ( 0, 0, 1, 1, "execute", true, inputWindow )
	clearButton = guiCreateButton ( 0, 0, 1, 1, "clear", true, inputWindow )
	settingsButton = guiCreateButton ( 0, 0, 1, 1, "settings", true, inputWindow )
	modeButton = guiCreateButton ( 0, 0, 1, 1, serverMode and "server" or "client", true, inputWindow )
	guiWindowSetSizable ( inputWindow, true )
	guiWindowSetSizable ( outputWindow, true )
	guiWindowSetMovable ( inputWindow, true )
	guiWindowSetMovable ( outputWindow, true )
	guiMemoSetReadOnly ( outputMemo, true )
end
local function applyMargin ( e, m, move )
	local pw, ph = guiGetSize ( getElementParent ( e ), false )
	local cw, ch = guiGetSize ( e, false )
	local cx, cy = guiGetPosition ( e, false )
	if move then
		guiSetPosition ( e, cx, cy + m, false )
	end
	guiSetSize ( e, cw, ch - m, false )
end
local function onResize ( window )
	window = window or source
	if getElementType ( window ) == 'gui-window' then
		local memo = getElementChildren ( window, 'gui-memo' ) [ 1 ]
		guiSetSize ( memo, 1, 1, true )
		applyMargin ( memo, windowHeaderSize )
		if memo == inputMemo then
			local w, h = guiGetSize ( memo, false )
			guiSetSize ( memo, w - toolbarWidth, h, false )
			local pw, ph = guiGetSize ( window, false )
			ph = ph - windowHeaderSize
			guiSetPosition ( sendButton, pw - toolbarWidth, windowHeaderSize, false )
			guiSetPosition ( clearButton, pw - toolbarWidth, ph/4 + windowHeaderSize, false )
			guiSetPosition ( settingsButton, pw - toolbarWidth, ph/4 * 2 + windowHeaderSize, false )
			guiSetPosition ( modeButton, pw - toolbarWidth, ph/4 * 3 + windowHeaderSize, false )
			guiSetSize ( sendButton, toolbarWidth, ph/4, false )
			guiSetSize ( clearButton, toolbarWidth, ph/4, false )
			guiSetSize ( settingsButton, toolbarWidth, ph/4, false )
			guiSetSize ( modeButton, toolbarWidth, ph/4, false )
		end
	end
end
function printToOutputMemo ( s )
	return guiSetText ( outputMemo, guiGetText ( outputMemo ) .. s )
end
onResize ( inputWindow )
onResize ( outputWindow )
applyMargin ( inputMemo, windowHeaderSize, true )
applyMargin ( outputMemo, windowHeaderSize, true )
addEventHandler ( 'onClientGUISize', resourceRoot, onResize )
addEventHandler ( 'onClientGUIClick', resourceRoot,
	function ( button )
		if button == 'left' then
			if source == sendButton then
				local buf = guiGetText ( inputMemo )
				if serverMode then
					triggerServerEvent ( 'executeOnServer', resourceRoot, buf )
				else
					local f, e = loadstring ( 'return ' .. buf )
					if not f then
						f, e = loadstring ( buf )
					end
					if f then
						(function (...)
							if includeTypeInOutput then
								for i = 1, arg.n do
									arg [ i ] = '[' .. type ( arg [ i ] ) .. '] ' .. tostring ( arg [ i ] )
								end
							else
								for i = 1, arg.n do
									arg [ i ] = tostring ( arg [ i ] )
								end
							end
							printToOutputMemo ( table.concat ( arg , ', ' ) )
						end) ( f () )
					else
						printToOutputMemo ( e )
					end
				end
			elseif source == clearButton then
				guiSetText ( outputMemo, '' )
			elseif source == modeButton then
				serverMode = not serverMode
				guiSetText ( modeButton, serverMode and "server" or "client" )
			end
		end
	end
)
addEvent ( 'onServerExecute', true )
addEventHandler ( 'onServerExecute', resourceRoot,
	function ( response )
		printToOutputMemo ( response )
	end
)