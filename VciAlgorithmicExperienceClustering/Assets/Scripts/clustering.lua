local Data = require "data"
local function_tools = require "function_tools"

-- Clusteringクラス（？）
-- 	k-means計算機
local Clustering = { }
Clustering.new = function(positions, k)
	-- param positions: データの座標のリスト
	-- param k: クラスター数k
	local instance = { }
	instance.__positions = positions
	instance.__length = #positions
	instance.__datas = { }
	instance.__k = k
	instance.__centers = { }

	instance.get_datas = function( )
		return instance.__datas
	end

	instance.initialize = function( )
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
	end

	instance.k_means = function( )
		-- クラスタリングの計算をします。
		instance.__calculate_centers( )
		instance.__re_calculate_cluster( )
	end

	instance.__calculate_centers = function( )
		-- すべてのクラスターの重心を計算します。
		for i = 0, instance.__k - 1 do
			instance.__calculate_center(i)
		end
	end

	instance.__calculate_center = function(i)
		-- 特定のクラスターの重心を計算します。
		-- param i: 計算するクラスター番号
		-- i番クラスターに属すデータのみ抽出
		local cluster_i = function_tools.filter_keep_key(function(data) return data:get_cluster( ) == i end, instance.__datas)
		-- 座標データのみ抽出
		local positions_i = { }
		for key, value in pairs(cluster_i) do
			table.insert(positions_i, value:get_position( ))
		end
		-- 重心を更新
		instance.__centers[i] = function_tools.average(positions_i)
	end

	instance.__re_calculate_cluster = function( )
		-- クラスターを再割当てします。
		-- すべてのデータiに対して，それぞれのクラスターjとの距離を計算 → 距離が1番近いクラスターに再割当て
		for i, data in pairs(instance.__datas) do
			local distances = instance.__calculate_data_clusters_distance(i, data)
			local minimum_distance = function_tools.minimum_absolute(distances)
			instance.__update_new_cluster(i, minimum_distance)
		end
	end

	instance.__calculate_data_clusters_distance = function(i, data)
		-- データiとそれぞれのクラスターjとの距離を計算します。
		-- param i: とあるデータのインデックス
		-- param data: i番目のデータ
		-- return: 距離配列（key＝クラスター番号，value＝距離）
		local distances = { }
		for j, center in pairs(instance.__centers) do
			distances[j] = Vector3.Distance(data:get_position( ), center)
		end
		return distances
	end

	instance.__update_new_cluster = function(i, minimum_distance)
		-- データインスタンスを新しいクラスター番号に更新します。
		-- param i: とあるデータのインデックス
		-- param minimum_distance: 最小の距離のインデックスと距離の入ったテーブル
		local previous_cluster = instance.__datas[i]:get_cluster( )
		local now_cluster = minimum_distance["index"]
		instance.__datas[i]:set_previous_cluster(previous_cluster)
		instance.__datas[i]:set_cluster(now_cluster)
	end

end
return Clustering
