local Controller = require "controller"
local controller = Controller.new( )
controller:initialize( )


local onUse = function(use)
	-- param use: グリップしたSubItemの名前
	if use == "ButtonNext" then
		controller:on_button_next_use( )
	end
end
