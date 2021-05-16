local Clustering = require "clustering"


-- Controllerクラス（？）
local Controller = { }
Controller.new = function( )
	local instance = { }
	instance.__clustering = { }
	instance.__data_objects = { }
	instance.__mean_objetcs = { }
	instance.__positions = { }
	instance.__button_count = 0

	instance.initialize = function(self)
		for i = 0, 19 do
			self.__data_objects[i] = vci.assets.GetSubItem("Data (" .. tostring(i) .. ")")
		end
		for i = 0, 2 do
			self.__mean_objetcs[i] = vci.assets.GetSubItem("Mean (" .. tostring(i) .. ")")
		end
		self:__set_positions( )
		self.__clustering = Clustering.new(self.__positions, 3)
		self.__clustering:initialize( )
	end

	instance.__set_positions = function(self)
		-- データをランダムに配置します。
		for i = 0, 19 do
			local x = math.random( )
			local y = math.random( )
			local z = math.random( )
			local random_vector = Vector3.__new(x, y, z)
			self.__positions[i] = random_vector
			self.__data_objects[i].SetLocalPosition(random_vector)
		end
		-- 重心を上空2 kmに配置します。
		for i = 0, 2 do
			local vector = Vector3.__new(0, 2000, 0)
			self.__mean_objetcs[i].SetLocalPosition(vector)
		end
	end

	instance.__get_positions = function(self)
		-- データの座標を再取得します。
		local datas = self.__clustering:get_datas( )
		for i = 0, 19 do
			local position = self.__data_objects[i].GetLocalPosition( )
			datas[i]:set_position(position)
		end
	end

	instance.__set_mean_object_postion = function(self, centers)
		-- 重心の座標を更新します
		for i = 0, 2 do
			self.__mean_objetcs[i].SetLocalPosition(centers[i])
		end
	end

	instance.__set_data_object_color = function(self, clusters)
		-- クラスター番号に合わせて，Dataオブジェクトの色を変更します。
		-- param clusters: クラスター番号の配列
		for i = 0, 19 do
			if clusters[i] == 0 then
				-- ここではマテリアル名（Data n）を使う。
				vci.assets.material._ALL_SetColor("Data " .. i, Color.__new(0.625, 1.0, 1.0))
			end
			if clusters[i] == 1 then
				vci.assets.material._ALL_SetColor("Data " .. i, Color.__new(1.0, 0.625, 1.0))
			end
			if clusters[i] == 2 then
				vci.assets.material._ALL_SetColor("Data " .. i, Color.__new(1.0, 1.0, 0.625))
			end
		end
	end

	instance.on_button_next_use = function(self)
		-- ボタンを押したときのイベントハンドラー。クラスタリングを実行し，結果に合わせて色を変える。
		self.__button_count = self.__button_count + 1
		self:__get_positions( )
		if self.__button_count == 1 then
			-- ステップ1：ランダムにグループ分け
			print("ステップ1　ランダムにグループ分け")
			local datas = self.__clustering:get_datas( )
			print("データ数：" .. #datas + 1 .. " 個")
			local clusters = { }
			for i = 0, #datas do
				clusters[i] = datas[i]:get_cluster( )
			end
			self:__set_data_object_color(clusters)
			return
		end
		if self.__button_count % 2 == 0 then
			-- ステップ2：各グループの平均を求める
			print("ステップ2　各グループの平均を求める")
			self.__clustering:calculate_centers( )
			local centers = self.__clustering:get_centers( )
			self:__set_mean_object_postion(centers)
			return
		end
		if self.__button_count % 2 == 1 then
			-- ステップ3：各データのグループ再割当て
			print("ステップ3　各データのグループを再割当て")
			self.__clustering:re_calculate_cluster( )
			local datas = self.__clustering:get_datas( )
			local clusters = { }
			for i = 0, #datas do
				clusters[i] = datas[i]:get_cluster( )
			end
			self:__set_data_object_color(clusters)
			return
		end
	end


	return instance
end
return Controller
