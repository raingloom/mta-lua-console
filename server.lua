addEvent ( 'executeOnServer', true )
addEventHandler ( 'executeOnServer', resourceRoot,
	function ( buf, includeTypeInOutput )
		local response
		local f, e = loadstring ( 'return ' .. buf )
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
				response = table.concat ( arg , ', ' )
			end) ( f () )
		else
			response = e
		end
		triggerClientEvent ( client, 'onServerExecute', resourceRoot, response )
	end
)