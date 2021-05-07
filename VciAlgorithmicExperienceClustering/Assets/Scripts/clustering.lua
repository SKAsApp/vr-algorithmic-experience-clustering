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
	print("clusteringデータ数：" .. #positions .. " 個")
	instance.__datas = { }
	instance.__k = k
	instance.__centers = { }

	instance.get_datas = function(self)
		return self.__datas
	end

	instance.initialize = function(self)
		-- テキトーにクラスター番号を割り振ります。
		print("initialize：テキトーにクラスター番号を割り振ります。")
		local separation = math.floor(self.__length / self.__k)
		for i = 0, separation do
			self.__datas[i] = Data.new(self.__positions[i], 0)
		end
		for i = separation + 1, separation * 2 do
			self.__datas[i] = Data.new(self.__positions[i], 1)
		end
		for i = separation * 2 + 1, self.__length do
			self.__datas[i] = Data.new(self.__positions[i], 2)
		end
	end

	instance.k_means = function(self)
		-- クラスタリングの計算をします。
		self:__calculate_centers( )
		self:__re_calculate_cluster( )
	end

	instance.__calculate_centers = function(self)
		-- すべてのクラスターの重心を計算します。
		for i = 0, self.__k - 1 do
			self:__calculate_center(i)
		end
	end

	instance.__calculate_center = function(self, i)
		-- 特定のクラスターの重心を計算します。
		-- param i: 計算するクラスター番号
		-- i番クラスターに属すデータのみ抽出
		local cluster_i = function_tools.filter_keep_key(function(data) return data:get_cluster( ) == i end, self.__datas)
		-- 座標データのみ抽出
		local positions_i = { }
		for key, value in pairs(cluster_i) do
			table.insert(positions_i, value:get_position( ))
		end
		-- 重心を更新
		self.__centers[i] = function_tools.average_vec3(positions_i)
		print("重心" .. i .. "：(" .. self.__centers[i].x .. ", " .. self.__centers[i].y .. ", " .. self.__centers[i].z .. ")")
	end

	instance.__re_calculate_cluster = function(self)
		-- クラスターを再割当てします。
		print("クラスターを再割当てします。")
		-- すべてのデータiに対して，それぞれのクラスターjとの距離を計算 → 距離が1番近いクラスターに再割当て
		for i, data in pairs(self.__datas) do
			local distances = self:__calculate_data_clusters_distance(data)
			local minimum_distance = function_tools.minimum_absolute(distances)
			self:__update_new_cluster(i, minimum_distance)
		end
	end

	instance.__calculate_data_clusters_distance = function(self, data)
		-- データiとそれぞれのクラスターjとの距離を計算します。
		-- param data: i番目のデータ
		-- return: 距離配列（key＝クラスター番号，value＝距離）
		local distances = { }
		for j, center in pairs(self.__centers) do
			distances[j] = Vector3.Distance(data:get_position( ), center)
		end
		return distances
	end

	instance.__update_new_cluster = function(self, i, minimum_distance)
		-- データインスタンスを新しいクラスター番号に更新します。
		-- param i: とあるデータのインデックス
		-- param minimum_distance: 最小の距離のインデックスと距離の入ったテーブル
		local previous_cluster = self.__datas[i]:get_cluster( )
		local now_cluster = minimum_distance["index"]
		self.__datas[i]:set_previous_cluster(previous_cluster)
		self.__datas[i]:set_cluster(now_cluster)
	end


	return instance
end
return Clustering
