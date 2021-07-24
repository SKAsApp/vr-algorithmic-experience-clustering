local Clustering = require "clustering"
local function_tools = require "function_tools"


-- Controllerクラス（？）
local Controller = { }
Controller.new = function( )
	local instance = { }
	instance.__clustering = { }
	instance.__data_objects = { }
	instance.__mean_objetcs = { }
	instance.__positions = { }
	instance.__centre_object = vci.assets.GetTransform("Centre")
	instance.__button_count = 0

	instance.initialise = function(self)
		-- データと重心のExportTransformを取得
		for i = 0, 19 do
			self.__data_objects[i] = vci.assets.GetTransform("Data (" .. tostring(i) .. ")")
		end
		for i = 0, 2 do
			self.__mean_objetcs[i] = vci.assets.GetTransform("Mean (" .. tostring(i) .. ")")
		end
		-- 初期化
		self:__set_initial_positions( )
		self:__initialise_state( )
	end

	instance.__set_initial_positions = function(self)
		-- 呼び出し時は全部上空2 kmに配置します。
		-- データ
		for i = 0, 19 do
			local vector = Vector3.__new(0, 2000, 0)
			self.__data_objects[i].SetLocalPosition(vector)
		end
		-- 重心
		for i = 0, 2 do
			local vector = Vector3.__new(0, 2000, 0)
			self.__mean_objetcs[i].SetLocalPosition(vector)
		end
	end

	instance.__set_random_positions = function(self)
		-- データを中心オブジェクトを中心にランダムに配置します。
		local centre_position = self.__centre_object.GetPosition( )
		for i = 0, 19 do
			local x = math.random( ) - 0.5
			local y = math.random( ) - 0.5
			local z = math.random( ) - 0.5
			local random_vector = Vector3.__new(x, y, z)
			self.__positions[i] = function_tools.add_vec3(random_vector, centre_position)
			self.__data_objects[i].SetPosition(self.__positions[i])
		end
		-- 重心を上空2 kmに配置します。
		for i = 0, 2 do
			local vector = Vector3.__new(0, 2000, 0)
			self.__mean_objetcs[i].SetLocalPosition(vector)
		end
	end

	instance.__initialise_state = function( )
		-- 色状態を初期化します。
		for i = 0, 19 do
			vci.state.Set("data " .. i .. "_previous_color", 0)
			vci.state.Set("data " .. i .. "_color", 0)
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
			local previous_color = vci.state.Get("data " .. i .. "_color")
			vci.state.Set("data " .. i .. "_previous_color", previous_color)
			vci.state.Set("data " .. i .. "_color", clusters[i])
		end
	end

	instance.on_button_next_use = function(self)
		-- ボタンを押したときのイベントハンドラー。クラスタリングを実行し，結果に合わせて色を変える。
		self.__button_count = self.__button_count + 1
		if self.__button_count == 1 then
			self:__step0( )
			return
		end
		self:__get_positions( )
		if self.__button_count == 2 then
			self:__step1( )
			return
		end
		if self.__button_count % 2 == 1 then
			self:__step2( )
			return
		end
		if self.__button_count % 2 == 0 then
			self:__step3( )
			return
		end
	end

	instance.__step0 = function(self)
		-- ステップ0：ランダムに配置し、clusteringインスタンスの初期化
		self:__set_random_positions( )
		self.__clustering = Clustering.new(self.__positions, 3)
		self.__clustering:initialise( )
	end

	instance.__step1 = function(self)
		-- ステップ1：ランダムにグループ分け
		print("ステップ1　ランダムにグループ分け")
		local datas = self.__clustering:get_datas( )
		print("データ数：" .. #datas + 1 .. " 個")
		local clusters = { }
		for i = 0, #datas do
			clusters[i] = datas[i]:get_cluster( )
		end
		self:__set_data_object_color(clusters)
	end

	instance.__step2 = function(self)
		-- ステップ2：各グループの平均を求める
		print("ステップ2　各グループの平均を求める")
		self.__clustering:calculate_centers( )
		local centers = self.__clustering:get_centers( )
		self:__set_mean_object_postion(centers)
	end

	instance.__step3 = function(self)
		-- ステップ3：各データのグループ再割当て
		print("ステップ3　各データのグループを再割当て")
		self.__clustering:re_calculate_cluster( )
		local datas = self.__clustering:get_datas( )
		local clusters = { }
		for i = 0, #datas do
			clusters[i] = datas[i]:get_cluster( )
		end
		self:__set_data_object_color(clusters)
	end

	instance.set_data_color = function(self, data_number)
		-- 色ステートの変更があった場合にデータオブジェクト1つの色を変えます。
		-- data_number Number: データオブジェクト番号
		local previous_color = vci.state.Get("data " .. data_number .. "_previous_color")
		local data_color = vci.state.Get("data " .. data_number .. "_color")
		if previous_color ~= data_color and data_color == 0 then
			-- ここではマテリアル名（Data n）を使う。
			vci.assets.material._ALL_SetColor("Data " .. data_number, Color.__new(0.625, 1.0, 1.0))
			return
		end
		if previous_color ~= data_color and data_color == 1 then
			vci.assets.material._ALL_SetColor("Data " .. data_number, Color.__new(1.0, 0.625, 1.0))
			return
		end
		if previous_color ~= data_color and data_color == 2 then
			vci.assets.material._ALL_SetColor("Data " .. data_number, Color.__new(1.0, 1.0, 0.625))
			return
		end
	end

	instance.update = function(self)
		-- 全ユーザー毎フレーム
		for i = 0, 19 do
			self:set_data_color(i)
		end
	end


	return instance
end
return Controller
