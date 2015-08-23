forbidden = { forbidden = true }

function record ()
	local mt = {}
	function mt:__newindex ( k, v )
		forbidden [ k ] = true
		rawset ( self, k, v )
	end
	setmetatable ( _G, mt )
end

forbidden.record = true
filteredEnv = setmetatable({},
	{
		__index = function ( self, k )
			if not forbidden [ k ] then
				local v = _G [ k ]
				rawset ( self, k, v )
				return v
			end
		end,
		__metatable = false,
	}
)
forbidden.filteredEnv = true