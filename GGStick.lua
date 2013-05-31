-- Project: GGStick
--
-- Date: May 23, 2013
--
-- File name: GGStick.lua
--
-- Author: Graham Ranson of Glitch Games - www.glitchgames.co.uk
--
-- Comments: 
-- 
--		GGStick is an easy to use virtual thumb-stick module for games. You can have as many 
--		as you like all playing nicely together.
--
-- Requirements: 
--
--
-- Copyright (C) 2012 Graham Ranson, Glitch Games Ltd.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this 
-- software and associated documentation files (the "Software"), to deal in the Software 
-- without restriction, including without limitation the rights to use, copy, modify, merge, 
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or 
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
----------------------------------------------------------------------------------------------------

local GGStick = {}
local GGStick_mt = { __index = GGStick }

local abs = math.abs
local atan = math.atan
local rad = math.rad
local deg = math.deg
local pi = math.pi
local pi2 = pi * 2
local sqrt = math.sqrt
local floor = math.floor
local cos = math.cos
local sin = math.sin

--- Initiates a new GGStick object.
-- @param params Table containing setup options. Optional.
-- @return The new object.
function GGStick:new( params )

	local self = {}

	setmetatable( self, GGStick_mt )
	
	self.params = params or {}
	
	self.radius = self.params.radius
	self.alpha = self.params.alpha or 1
	self.fadeInTime = self.params.fadeInTime or 0
	self.fadeOutTime = self.params.fadeOutTime or 500
	self.instantResetOnRelease = self.params.instantResetOnRelease
	
	self.otherStickIDs = {}
	
	self:onReset()
	
	Runtime:addEventListener( "touch", self )
	Runtime:addEventListener( "ggStick", self )
	
    return self
    
end

--- Calculates the distance between two points. Used internally.
-- @param x1 The x position of the first point.
-- @param y1 The y position of the first point.
-- @param x2 The x position of the second point.
-- @param y2 The y position of the second point.
-- @return The distance.
function GGStick:calculateDistance( x1, y1, x2, y2 )
	
	if not x1 or not y1 or not x2 or not y2 then
		return
	end
	
	local factor = { x = x2 - x1, y = y2 - y1 }

	return sqrt( ( factor.x * factor.x ) + ( factor.y * factor.y ) )

end

--- Calculates the angle between two points. Used internally.
-- @param x1 The x position of the first point.
-- @param y1 The y position of the first point.
-- @param x2 The x position of the second point.
-- @param y2 The y position of the second point.
-- @return The angle.
function GGStick:calculateAngle( x1, y1, x2, y2 )
	
	if not x1 or not y1 or not x2 or not y2 then
		return
	end
	
	local distance = { x = x2 - x1, y = y2 - y1 }

	if distance then

		local angleBetween = atan( distance.y / distance.x )
	
	    if ( x1 < x2 ) then 
			angleBetween = angleBetween + rad( 90 ) 
		else 
			angleBetween = angleBetween + rad( 270 ) 
		end		
		
		if angleBetween == pi or angleBetween == pi2 then
  			angleBetween = angleBetween - rad( 180 )
		end

		angleBetween = deg( angleBetween )
		
		return angleBetween
	
	end

	return nil
	
end

--- Called when the touch event has began. Used internally.
-- @param x The x position of the touch event.
-- @param y The y position of the touch event.
-- @param id The id of the touch event.
function GGStick:onBegin( x, y, id )
	
	self:onReset()

	self.origin = { x = x, y = y } 
	self.id = id

	self.visual = display.newGroup()
	
	if self.params.outer then
	
		local path = self.params.outer
		local width = nil
		local height = nil
		
		if type( self.params.outer ) == "table" then
			path = self.params.outer.path
		    width = self.params.outer.width
		    height = self.params.outer.height
		end
		
		if width and height then
			self.outer = display.newImageRect( self.visual, path, width, height )
		else
			self.outer = display.newImage( self.visual, path )
			self.outer.x = self.outer.x - self.outer.contentWidth * 0.5
			self.outer.y = self.outer.y - self.outer.contentHeight * 0.5
		end
		
		if not self.radius then
			self.radius = self.outer.contentWidth * 0.5
		end
	
	else
		if not self.radius then
			self.radius = 40
		end
		self.outer = display.newCircle( self.visual, 0, 0, self.radius )
	end
	
	if self.params.inner then
		
		local path = self.params.inner
		local width = nil
		local height = nil
		
		if type( self.params.inner ) == "table" then
			path = self.params.inner.path
		    width = self.params.inner.width
		    height = self.params.inner.height
		end
		
		if width and height then
			self.inner = display.newImageRect( self.visual, path, width, height )
		else
			self.inner = display.newImage( self.visual, path )
			self.inner.x = self.inner.x - self.inner.contentWidth * 0.5
			self.inner.y = self.inner.y - self.inner.contentHeight * 0.5
		end
				
	else
		self.inner = display.newCircle( self.visual, 0, 0, self.radius * 0.3 )
		self.inner:setFillColor( 255, 0, 0 )
	end
	
	self.visual.x = x
	self.visual.y = y
	
	self.visual.alpha = 0
	transition.to( self.visual, { time = self.fadeInTime, alpha = self.alpha } )
	
	Runtime:dispatchEvent{ name = "ggStick", type = "created", id = self.id }
	
end

--- Called when the touch event has moved. Used internally.
-- @param x The x position of the touch event.
-- @param y The y position of the touch event.
function GGStick:onMove( x, y )

	-- Adjust X And Y
	x, y = ( self.origin.x - x ) * -1, ( self.origin.y - y ) * -1
	
	-- Calculate Vector, Angle, Distance, Magnitude and Position
	self.vector = { x = x / self.radius, y = y / self.radius }
	self.angle = floor( self:calculateAngle( 0, 0, x, y ) )
	self.distance = floor( self:calculateDistance( 0, 0, x, y ) )
	self.magnitude = floor( ( self.distance / self.radius ) * 10 ) / 10
	self.position = { x = x, y = y }
	
	-- Constrain Vector, Magnitude and Distance
	if self.vector.x < -1 then self.vector.x = -1
	elseif self.vector.x > 1 then self.vector.x = 1 end
	self.vector.x = floor( self.vector.x * 10 ) * 0.1
	
	if self.vector.y < -1 then self.vector.y = -1
	elseif self.vector.y > 1 then self.vector.y = 1 end
	self.vector.y = floor( self.vector.y * 10 ) * 0.1
	
	if self.magnitude < -1 then self.magnitude = -1
	elseif self.magnitude > 1 then self.magnitude = 1 end
	
	if self.distance > self.radius then self.distance = self.radius end
	
	-- Constrain Position
	if abs( self.magnitude ) == 1 then
		local radians = rad( self.angle - 90 )
		x = cos( radians ) * self.radius
		y = sin( radians ) * self.radius
		self.position = { x = floor( x ), y = floor( y ) }	
    end
    
    -- Reposition Inner
    self.inner.x = x
	self.inner.y = y  
    
end

--- Called when the touch event has ended or been cancelled. Used internally.
function GGStick:onEnd()

	local tempUpdate = function()
		if self.visual then
			local x, y = self.visual:localToContent( self.inner.x, self.inner.y )
			x = floor( x )
			y = floor( y )
			self:onMove( x, y )
		end
	end
	
	local onComplete = function()
		Runtime:removeEventListener( "enterFrame", tempUpdate )
		display.remove( self.visual )
		self.visual = nil
		self:onReset()
	end
	transition.to( self.visual, { time = self.fadeOutTime, alpha = 0, onComplete = onComplete } )	
	
	if self.instantResetOnRelease then
		self:onReset()
	else
		transition.to( self.inner, { time = self.fadeOutTime, x = 0, y = 0 } )
		Runtime:addEventListener( "enterFrame", tempUpdate )
	end
	
	Runtime:dispatchEvent{ name = "ggStick", type = "destroyed", id = self.id }
		
end

--- Called when the touch event has ended or been cancelled. Used internally.
function GGStick:onReset()
	self.id = nil
	self.angle = 0
	self.distance = 0
	self.magnitude = 0
	self.vector = { x = 0, y = 0 }
	self.position = { x = 0, y = 0 }
end

--- Handler function for the touch event. Used internally.
-- @param event The event.
function GGStick:touch( event )

	local phase = event.phase
	local x, y = event.x, event.y
	local id = event.id
	
	if self.id and id ~= self.id or self.otherStickIDs[ id ] then
		return
	end
	
	if phase == "began" then
		self:onBegin( x, y, id )
	elseif phase == "moved" then
		self:onMove( x, y )
	else
		self:onEnd()
	end
	
end

--- Handler function for the ggStick event. Used internally.
-- @param event The event.
function GGStick:ggStick( event )
	if event.id and event.id ~= self.id then
		if event.type == "created" then
			self.otherStickIDs[ event.id ] = true
		elseif event.type == "destroyed" then
			self.otherStickIDs[ event.id ] = nil
		end
	end
end

--- Gets the angle of the stick.
-- @return The angle.
function GGStick:getAngle()
	return self.angle
end

--- Gets the distance of the inner stick from the origin point.
-- @return The distance.
function GGStick:getDistance()
	return self.distance
end

--- Gets the magnitude of the stick.
-- @return A normalised value between 0 and 1.
function GGStick:getMagnitude()
	return self.magnitude
end

--- Gets the vector of the stick.
-- @return A table containing x and y values, normalised between -1 and 1.
function GGStick:getVector()
	return self.vector
end

--- Gets the position of the inner stick relative to the origin point.
-- @return A table containing x and y values.
function GGStick:getPosition()
	return self.position
end

--- Gets the origin point of this stick, i.e. where the visual is.
-- @return A table containing x and y values.
function GGStick:getOrigin()
	return self.origin
end

--- Destroys the GGStick object.
function GGStick:destroy()
	Runtime:removeEventListener( "touch", self )
	Runtime:removeEventListener( "ggStick", self )
	display.remove( self.visual )
	self.visual = nil
end

return GGStick