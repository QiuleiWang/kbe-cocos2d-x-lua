
local MyApp = class("MyApp", cc.load("mvc").AppBase)
package.path = package.path..";app/"
require("kbe_model/init")
function MyApp:onCreate()
    math.randomseed(os.time())
    local args=KBEngine.KBEngineArgs()
    args.ip = "103.72.166.71"
	args.port = 20013
    KBEngine.new(args)
end

return MyApp
