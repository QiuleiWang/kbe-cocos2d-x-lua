
local MyApp = class("MyApp", cc.load("mvc").AppBase)
package.path = package.path..";app/"
require("kbe_model/init")
require("extend/display_extend")
cc.exports["UINode"]= require("views.ui.UINode")
cc.exports["UIButton"]= require("views.ui.UIButton")
cc.exports["UIImage"]= require("views.ui.UIImage")
cc.exports["UIScrollView"]= require("views.ui.UIScrollView")
cc.exports["UITableView"]= require("views.ui.UITableView")

function MyApp:onCreate()
    math.randomseed(os.time())
    local args=KBEngine.KBEngineArgs()
    args.ip = "127.0.0.1"
	args.port = 20013
    KBEngine.new(args)
end

return MyApp
