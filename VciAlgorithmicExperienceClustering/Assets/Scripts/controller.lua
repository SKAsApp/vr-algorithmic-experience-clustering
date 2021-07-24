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
	instance.__previous_positions = { }
	instance.__centre_object = vci.assets.GetTransform("Centre")
	instance.__button_count = 0
	instance.__is_finished = false

	instance.__set_positions = function(self, index, value)
		-- positionsをprevious_positionsに保持し、positionsを更新します。
		-- param index Number: positions配列のインデックス
		self.__previous_positions[index] = self.__positions[index]
		self.__positions[index] = value
	end

	instance.initialise = function(self)
		-- データと重心のExportTransformを取得
		for i = 0, 19 do
			self.__data_objects[i] = vci.assets.GetTransform("Data (" .. tostring(i) .. ")")
		end
		for i = 0, 2 do
			self.__mean_objetcs[i] = vci.assets.GetTransform("Mean (" .. tostring(i) .. ")")
		end
		self:__initialise_main(false)
	end

	instance.__initialise_main = function(self, is_reset)
		-- 初期化メイン処理
		-- param is_reset Bool: リセットボタンによるものか
		instance.__button_count = 0
		instance.__is_finished = false
		self:__set_initial_positions( )
		self:__initialise_state(is_reset)
	end

	instance.__set_initial_positions = function(self)
		-- 呼び出し時は全部上空2 kmに配置します。
		-- データ
		for i = 0, 19 do
			local vector = Vector3.__new(0, 2000, 0)
			self:__set_positions(i, vector)
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
			self:__set_positions(i, function_tools.add_vec3(random_vector, centre_position))
			self.__data_objects[i].SetPosition(self.__positions[i])
		end
	end

	instance.__initialise_state = function(is_reset)
		-- 色状態を初期化します。
		-- param is_reset Bool: リセットボタンによるものか
		if is_reset then
			for i = 0, 19 do
				vci.state.Set("data " .. i .. "_color", 0)
			end
			return
		end
		for i = 0, 19 do
			vci.state.Set("data " .. i .. "_previous_color", 0)
			vci.state.Set("data " .. i .. "_color", 0)
		end
	end

	instance.__get_positions = function(self)
		-- データの座標を再取得します。
		local datas = self.__clustering:get_datas( )
		for i = 0, 19 do
			local position = self.__data_objects[i].GetPosition( )
			self:__set_positions(i, position)
			datas[i]:set_position(position)
		end
	end

	instance.__is_position_changed = function(self)
		-- データの座標が変わったか（手動で移動したかどうか判断します）
		for i = 0, 19 do
			if not function_tools.is_equal_vec3(self.__positions[i], self.__previous_positions[i]) then
				self.__is_finished = false
				print("データ動いた")
				return true
			end
		end
		return false
	end

	instance.__set_mean_object_postion = function(self, centers)
		-- 重心の座標を更新します
		local is_mean_changed = false
		for i = 0, 2 do
			if not function_tools.is_equal_vec3(self.__mean_objetcs[i].GetPosition( ), centers[i]) then
				is_mean_changed = true
				self.__mean_objetcs[i].SetPosition(centers[i])
			end
		end
		if not is_mean_changed then
			self.__is_finished = true
			print("収束しました")
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
		self:__is_position_changed( )
		if self.__is_finished then
			self.__button_count = self.__button_count - 1
			print("収束しています")
			return
		end
		self:__sound_next( )
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

	instance.__sound_next = function(self)
		-- 「次へ」ボタンを押したときの音を鳴らします
		vci.assets.audio._ALL_Play("decision17", 0.80, false)
	end

	instance.__step0 = function(self)
		-- ステップ0：ランダムに配置し、clusteringインスタンスの初期化
		print("ステップ0：ランダムにデータを配置")
		self:__sound_next( )
		self:__set_random_positions( )
		self:__force_color_change( )
		self.__clustering = Clustering.new(self.__positions, 3)
		self.__clustering:initialise( )
	end

	instance.__force_color_change = function(self)
		-- 強制的に色の更新をかけます。
		vci.state.Set("force_init_color", true)
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

	instance.on_button_reset_use = function(self)
		-- リセットボタンを押したとき。
		if self.__button_count == 0 then
			return
		end
		self:__sound_reset( )
		self:__initialise_main(true)
		self.__button_count = 0
		print("リセットしました")
	end

	instance.__sound_reset = function(self)
		-- 「リセット」ボタンを押したときの音を鳴らします
		vci.assets.audio._ALL_Play("decision1", 0.80, false)
	end

	instance.update = function(self)
		-- 全ユーザー毎フレーム
		if vci.state.Get("force_init_color") then
			for i = 0, 19 do
				vci.assets.material._ALL_SetColor("Data " .. i, Color.__new(0.625, 1.0, 1.0))
			end
			vci.state.Set("force_init_color", false)
		end
		for i = 0, 19 do
			self:set_data_color(i)
		end
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


	return instance
end
return Controller
