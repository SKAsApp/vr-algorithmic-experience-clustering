-- Dataクラス（？）
-- 	座標とクラスター番号を保持
local Data = { }
Data.new = function(position, cluster)
	-- param position: 座標：Vec3
	-- param cluster: クラスター番号：number
	local instance = { }
	instance.__position = position
	instance.__cluster = cluster
	instance.__previous_cluster = 0

	instance.get_position = function( )
		return instance.__position
	end

	instance.get_cluster = function( )
		return instance.__cluster
	end

	instance.set_cluster = function(value)
		instance.__cluster = value
	end

	instance.get_previous_cluster = function( )
		return instance.__previous_cluster
	end

	instance.set_previous_cluster = function(value)
		instance.__previous_cluster = value
	end

end
return Data
