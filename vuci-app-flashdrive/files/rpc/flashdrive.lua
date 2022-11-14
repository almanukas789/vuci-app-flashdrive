local utils = require "vuci.utils"
local rpc = require "vuci.rpc"
local fs = require "vuci.fs"

local M = {}

function M.get()
  	local handle = io.popen("fmt-usb-msd.sh unmountable")
    if handle == nil then
        return error()
    end
    local result = handle:read("*a")
    return { result }
end
function M.browse(params)
    local path = params.path
  	local handle = io.popen('ls ' .. path)
    if handle == nil then
        return error()
    end
    local result = handle:read("*a")
    return { result }
end

return M
