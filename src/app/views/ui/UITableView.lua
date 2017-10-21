local _M = class("UITableView", function(...)
        return cc.TableView:create(...)
end)
_M.numberOfCellsDelegate=nil
_M.cellSizeDelegate=nil
_M.cellIndexDelegate=nil

local UITABLE_HORIZONTAL=cc.SCROLLVIEW_DIRECTION_HORIZONTAL
local UITABLE_VERTICAL=cc.SCROLLVIEW_DIRECTION_VERTICAL

function _M:ctor()
    self:setOrientation(UITABLE_VERTICAL)
    self:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:setIgnoreAnchorPointForPosition(false)
    self:setDelegate()
end

function _M:create(...)
    local tableView = _M.new(...)
    return tableView
end

--rowNumCallback,sizeCallback,createCellCallback
function _M:setDelegateCallback(func,func1,func2)
  self:setNumberOfCellsDelegate(func)
  self:setCellSizeDelegate(func1)
  self:setCellIndexDelegate(func2)
end


function _M:setNumberOfCellsDelegate(func)
  self.numberOfCellsDelegate=func
  self:registerScriptHandler(self.numberOfCellsDelegate,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
  
end

function _M:setCellSizeDelegate(func)
  self.cellSizeDelegate=func
  self:registerScriptHandler(self.cellSizeDelegate,cc.TABLECELL_SIZE_FOR_INDEX)
   
end

function _M:setCellIndexDelegate(func)
    self.cellIndexDelegate=func
    self:registerScriptHandler(self.cellIndexDelegate,cc.TABLECELL_SIZE_AT_INDEX)
end


function _M:setOrientation(orientation)
    self:setDirection(orientation)
end

function _M:updateCell(index)
       self:updateCellAtIndex(index)
       self:refresh()         
end


function _M:insertCell(index)
       self:insertCellAtIndex(index)
       self:refresh()         
end

--row 0 开始
function _M:setContentOffsetWithRow(row)
      self:reloadData()   
     if self.cellSizeDelegate then
        local offsetY=0
        for i=0,row-1 do
          local width,height=self.cellSizeDelegate(self,1)
          offsetY=offsetY+height
        end
        self:setContentOffset(cc.p(0,-(self:getContentSize().height-offsetY)+self:getViewSize().height))
     end
     self:refresh()      
end 



function _M:removeCell(index)
       self:removeCellAtIndex(index)
       self:refresh()         
end    

function _M:refresh()
    local oldSize   = self:getContentSize()
    local oldOffset = self:getContentOffset()
    self:reloadData()
    local newOffset = self:getContentOffset()
    local newSize   = self:getContentSize()
    if oldSize.height==0 then
        oldOffset = newOffset
    else
        if newSize.height<self:getViewSize().height then    
            oldOffset.y = self:getViewSize().height-newSize.height
        else
            local tValue = newSize.height-oldSize.height
            oldOffset.y = oldOffset.y-tValue
            if oldOffset.y>0 then oldOffset.y=0 end
        end
    end
    self:setContentOffset(oldOffset)

end

return _M

