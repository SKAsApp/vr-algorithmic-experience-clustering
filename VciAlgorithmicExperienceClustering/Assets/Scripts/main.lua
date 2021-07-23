print("Controller読み込み")
local Controller = require "controller"
local controller = Controller.new( )
controller:initialize( )
print("controllerを生成し，初期化しました。")


onUse = function(use)
	-- （VCIのイベントハンドラー）グリップしたとき
	-- param use: グリップしたSubItemの名前
	print("onUseされ，" .. use .. "が押されました。")
	if use == "ButtonNext" then
		controller:on_button_next_use( )
	end
end


updateAll = function( )
	-- （VCIのイベントハンドラー）全ユーザーでの毎フレーム実行
	controller:update( )
end
