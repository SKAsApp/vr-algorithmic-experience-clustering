-- 便利な高階関数等
local function_tools = { }

function_tools.map = function(func, from_array)
	-- from_arrayにfuncを適用させた写像（to_array）を返します。
	local to_array = { }
	for key, value in pairs(from_array) do
		to_array[key] = func(value)
	end
	return to_array
end


function_tools.filter_keep_key = function(func, from_array)
	-- funcがtrueになるfrom_arrayの要素のみを抽出した配列（to_array）を返します。ただし，tableのkeyは保持します。
	local to_array = { }
	for key, value in pairs(from_array) do
		if func(value) then
			to_array[key] = value
		end
	end
	return to_array
end


function_tools.reduce = function(func, from_array)
	-- from_arrayをfuncで畳み込んだ結果を返します。
	local result = 0
	for key, value in pairs(from_array) do
		result = func(result, value)
	end
	return result
end


function_tools.reduce_keep_index = function(func, from_array)
	-- from_arrayをfuncで畳み込んだ結果を返します。ただし，インデックス順で，インデックスは1から要素がnilになるまでです。
	local result = 0
	for index, value in ipairs(from_array) do
		result = func(result, value)
	end
	return result
end


function_tools.average = function(from_array)
	-- 配列の平均値を返します。
	local sum = 0
	local count = 0
	for key, value in pairs(from_array) do
		count = count + 1
		sum = sum + value
	end
	return sum / count
end


function_tools.average_vec3 = function(from_array)
	-- vec3配列の平均値を返します。
	local sum_x = 0.0
	local sum_y = 0.0
	local sum_z = 0.0
	local count = 0
	for key, value in pairs(from_array) do
		count = count + 1
		sum_x = sum_x + value.x
		sum_y = sum_y + value.y
		sum_z = sum_z + value.z
	end
	return Vector3.__new(sum_x / count, sum_y / count, sum_z / count)
end


function_tools.add_vec3 = function(vec1, vec2)
	-- vec3の各成分同士を足します。
	return Vector3.__new(vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z)
end


function_tools.is_equal_vec3 = function(vec1, vec2)
	-- vec3の各成分が等しいか判断します。
	local equal_x = -0.000001 < vec1.x - vec2.x and vec1.x - vec2.x < 0.000001
	local equal_y = -0.000001 < vec1.y - vec2.y and vec1.y - vec2.y < 0.000001
	local equal_z = -0.000001 < vec1.z - vec2.z and vec1.z - vec2.z < 0.000001
	return equal_x and equal_y and equal_z
end


function_tools.minimum_absolute = function(from_array)
	-- 配列の絶対値が最小のインデックスと，その値を配列で返します。
	local result = { }
	local temp_index = 2147483647
	local temp_value = 2147483647
	for key, value in pairs(from_array) do
		-- 絶対値に変換
		local val = value
		if val < 0 then
			val = -1 * val
		end
		-- 小さい値をtempに格納
		if val < temp_value then
			temp_index = key
			temp_value = val
		end
	end
	-- 最終結果をresultに格納
	result["index"] = temp_index
	result["value"] = temp_value
	return result
end


return function_tools
