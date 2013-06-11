system.activate( "multitouch" )
local rad = math.rad
local cos = math.cos
local sin = math.sin

local GGStick = require( "GGStick" )

local bullets = {}

-- OUTPUT FOR STICK #1 --
local title1 = display.newText( "Stick #1", 0, 0, "Helvetica-Bold", 18 )
title1.x = ( title1.contentWidth * 0.5 ) + 10
title1.y = 30

local magnitude1 = display.newText( "Magnitude: 0", 0, 0, "Helvetica", 14 )
magnitude1.x = ( magnitude1.contentWidth * 0.5 ) + 10
magnitude1.y = 45

local angle1 = display.newText( "Angle: 0", 0, 0, "Helvetica", 14 )
angle1.x = ( angle1.contentWidth * 0.5 ) + 10
angle1.y = 60

local vector1 = display.newText( "Vector: 0", 0, 0, "Helvetica", 14 )
vector1.x = ( vector1.contentWidth * 0.5 ) + 10
vector1.y = 75

local position1 = display.newText( "Position: 0", 0, 0, "Helvetica", 14 )
position1.x = ( position1.contentWidth * 0.5 ) + 10
position1.y = 90

local distance1 = display.newText( "Distance: 0", 0, 0, "Helvetica", 14 )
distance1.x = ( distance1.contentWidth * 0.5 ) + 10
distance1.y = 105

-- OUTPUT FOR STICK #2 --
local title2 = display.newText( "Stick #2", 0, 0, "Helvetica-Bold", 18 )
title2.x = display.contentWidth - ( title2.contentWidth * 0.5 ) - 10
title2.y = 30

local magnitude2 = display.newText( "Magnitude: 0", 0, 0, "Helvetica", 14 )
magnitude2.x = display.contentWidth - ( magnitude2.contentWidth * 0.5 ) - 10
magnitude2.y = 45

local angle2 = display.newText( "Angle: 0", 0, 0, "Helvetica", 14 )
angle2.x = display.contentWidth - ( angle2.contentWidth * 0.5 ) - 10
angle2.y = 60

local vector2 = display.newText( "Vector: 0", 0, 0, "Helvetica", 14 )
vector2.x = display.contentWidth - ( vector2.contentWidth * 0.5 ) - 10
vector2.y = 75

local position2 = display.newText( "Position: 0", 0, 0, "Helvetica", 14 )
position2.x = display.contentWidth - ( position2.contentWidth * 0.5 ) - 10
position2.y = 90

local distance2 = display.newText( "Distance: 0", 0, 0, "Helvetica", 14 )
distance2.x = display.contentWidth - ( distance2.contentWidth * 0.5 ) - 10
distance2.y = 105

local player = display.newCircle( 0, 0, 10 )
player:setFillColor( 0, 255, 0 )
player.x = display.contentCenterX
player.y = display.contentCenterY
player.speed = 2
player.fireRate = 10
player.framesSinceLastFire = 0

-- Make a basic stick
local stick1 = GGStick:new()

-- Make a customised one
local stick2 = GGStick:new
{
	--radius = 30, 
	alpha = 0.7, 
	fadeInTime = 100,
	instantResetOnRelease = true,
	outer = { path = "outer.png", width = 50, height = 50 },
	inner = { path = "inner.png", width = 10, height = 10 }
}

local fire = function( x, y, angle )
	
	local bullet = display.newCircle( 0, 0, 5 )
	bullet:setFillColor( 255, 0, 0 )
	bullet.x = x
	bullet.y = y
	
	local radians = rad( angle + 90 )
	bullet.vX = cos( radians ) * -1
	bullet.vY = sin( radians ) * -1
	bullet.speed = 5
	
	-- Rudimentary clean up, naturally this isn't good enough for a real game :-)
	timer.performWithDelay( 5000, function() bullet.removeMe = true end, 1 )
	
	bullets[ #bullets + 1 ] = bullet
		
end

local onUpdate = function( event )
	
	player.x = player.x + ( stick1.vector.x * player.speed )
	player.y = player.y + ( stick1.vector.y * player.speed )
	
	if stick2.magnitude ~= 0 then
		if not player.framesSinceLastFire or player.framesSinceLastFire >= player.fireRate then
			fire( player.x, player.y, stick2.angle )
			player.framesSinceLastFire = 0
		end
		player.framesSinceLastFire = player.framesSinceLastFire + 1
	end
	
	magnitude1.text = "Magnitude: " .. stick1:getMagnitude() 
	magnitude1.x = ( magnitude1.contentWidth * 0.5 ) + 10
	
	angle1.text = "Angle: " .. stick1:getAngle() 
	angle1.x = ( angle1.contentWidth * 0.5 ) + 10
	
	vector1.text = "Vector: X - " .. stick1:getVector().x  .. " | Y - " .. stick1:getVector().y
	vector1.x = ( vector1.contentWidth * 0.5 ) + 10
	
	position1.text = "Position: X - " .. stick1:getPosition().x  .. " | Y - " .. stick1:getPosition().y
	position1.x = ( position1.contentWidth * 0.5 ) + 10
	
	distance1.text = "Distance: " .. stick1:getDistance() 
	distance1.x = ( distance1.contentWidth * 0.5 ) + 10
	
	magnitude2.text = "Magnitude: " .. stick2:getMagnitude() 
	magnitude2.x = display.contentWidth - ( magnitude2.contentWidth * 0.5 ) - 10
	
	angle2.text = "Angle: " .. stick2:getAngle() 
	angle2.x = display.contentWidth - ( angle2.contentWidth * 0.5 ) - 10
	
	vector2.text = "Vector: X - " .. stick2:getVector().x  .. " | Y - " .. stick2:getVector().y
	vector2.x = display.contentWidth - ( vector2.contentWidth * 0.5 ) - 10
	
	position2.text = "Position: X - " .. stick2:getPosition().x  .. " | Y - " .. stick2:getPosition().y
	position2.x = display.contentWidth - ( position2.contentWidth * 0.5 ) - 10
	
	distance2.text = "Distance: " .. stick2:getDistance() 
	distance2.x = display.contentWidth - ( distance2.contentWidth * 0.5 ) - 10
	
	for i = #bullets, 1, -1 do
		if bullets[ i ].removeMe then
			local bullet = table.remove( bullets, i )
			display.remove( bullet )
			bullet = nil
		else
			bullets[ i ].x = bullets[ i ].x + ( bullets[ i ].vX * bullets[ i ].speed )
			bullets[ i ].y = bullets[ i ].y + ( bullets[ i ].vY * bullets[ i ].speed )
		end
	end
	
end
Runtime:addEventListener( "enterFrame", onUpdate )