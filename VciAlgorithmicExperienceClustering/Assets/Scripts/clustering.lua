local Data = require "data"

-- Clusteringクラス
-- 	k-meansの計算をします。
local Clustering = { }
Clustering.new = function(positions, k)
	-- param positions: データの座標のリスト
	-- param k: クラスター数k
	local instance = { }
	instance.__positions = positions
	instance.__length = #datas
	-- datasはDataインスタンスのリスト
	instance.__datas = { }
	instance.__k = k

	instance.__initialize = function( )
		-- テキトーにクラスター番号を割り振ります。
		local separation = math.floor(instance.__length / instance.__k)
		for i = 0, separation do
			instance.datas[i] = Data.new(instance.__positions[i], 0)
		end
		for i = separation + 1, separation * 2 do
			instance.datas[i] = Data.new(instance.__positions[i], 1)
		end
		for i = separation * 2 + 1, instance.__length do
			instance.datas[i] = Data.new(instance.__positions[i], 2)
		end

	instance.get_position = function( )
		return instance.__position
	end

end
return Clustering