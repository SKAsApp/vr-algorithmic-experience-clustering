-- Dataクラス
-- 	座標とクラスター番号を保持
local Data = { }
Data.new = function(position, cluster)
	-- param position: 座標：Vec3
	-- param cluster: クラスター番号：number
	local instance = { }
	instance.__position = position
	instance.__cluster = cluster

	instance.get_position = function( )
		return instance.__position
	end

	instance.get_cluster = function( )
		return instance.__cluster
	end

end
return Data
