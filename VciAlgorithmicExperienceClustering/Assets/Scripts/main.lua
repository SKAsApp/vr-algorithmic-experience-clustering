print("Controller読み込み")
local Controller = require "controller"
local controller = Controller.new( )
controller:initialise( )
print("controllerを生成し，初期化しました。")


onUse = function(use)
	-- （VCIのイベントハンドラー）グリップしたとき
	-- param use: グリップしたSubItemの名前
	print("onUseされ，" .. use .. "が押されました。")
	if use == "ButtonNext" then
		controller:on_button_next_use( )
		return
	end
	if use == "ButtonReset" then
		controller:on_button_reset_use( )
		return
	end
end


updateAll = function( )
	-- （VCIのイベントハンドラー）全ユーザーでの毎フレーム実行
	controller:update( )
	return
end
