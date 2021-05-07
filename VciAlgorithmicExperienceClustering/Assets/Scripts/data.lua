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

	instance.get_position = function(self)
		return self.__position
	end

	instance.set_position = function(self, value)
		self.__position = value
	end

	instance.get_cluster = function(self)
		return self.__cluster
	end

	instance.set_cluster = function(self, value)
		self.__cluster = value
	end

	instance.get_previous_cluster = function(self)
		return self.__previous_cluster
	end

	instance.set_previous_cluster = function(self, value)
		self.__previous_cluster = value
	end


	return instance
end
return Data
