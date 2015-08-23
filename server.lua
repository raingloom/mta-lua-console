record()
addEvent ( 'executeOnServer', true )
addEventHandler ( 'executeOnServer', resourceRoot,
	function ( buf, includeTypeInOutput )
		local response
		local f, e = loadstring ( buf )
		if f then
			setfenv ( f, filteredEnv );
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