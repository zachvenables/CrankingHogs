import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

local playerSprite = nil

local playerSpeed = 4

local playTimer = nil
local playTime = 30 * 1000

local coinSprite = nil
local score = 0


local stickFigure = {
	head = { x = 45, y = 20, width = 10, height = 10 },
	body = { x = 50, y = 30, width = 2, height = 20 },
	leftArm = { x = 40, y = 30, width = 10, height = 2 },
	rightArm = { x = 50, y = 30, width = 10, height = 2 },
	hip = { x = 45, y = 50, width = 10, height = 2 },
	leftLeg = { x = 45, y = 50, width = 2, height = 20 },
	rightLeg = { x = 55, y = 50, width = 2, height = 20 },
	roadSpot = { x = 146, y = 116 }
}

  function drawStickFigure(stickman)
    drawRect(stickman.head.x, stickman.head.y, stickman.head.width, stickman.head.height)
    drawRect(stickman.body.x, stickman.body.y, stickman.body.width, stickman.body.height)
    drawRect(stickman.leftArm.x, stickman.leftArm.y, stickman.leftArm.width, stickman.leftArm.height)
    drawRect(stickman.rightArm.x, stickman.rightArm.y, stickman.rightArm.width, stickman.rightArm.height)
	drawRect(stickman.hip.x, stickman.hip.y, stickman.hip.width, stickman.hip.height)
    drawRect(stickman.leftLeg.x, stickman.leftLeg.y, stickman.leftLeg.width, stickman.leftLeg.height)
    drawRect(stickman.rightLeg.x, stickman.rightLeg.y, stickman.rightLeg.width, stickman.rightLeg.height)
  end

  function drawRect(x, y, width, height)
    -- Implement your rendering code here to draw a rectangle at the given coordinates
	gfx.drawRect(x, y, width, height)
	
  end

  function moveStickFigure(stickman)
	if not inRoad(stickman) then
		changeStickFigureX(stickman)
		changeStickFigureY(stickman)
  	end
	  drawStickFigure(stickman)
  end

  function inRoad(stickman)
	return stickman.head.x > stickman.roadSpot.x
  end

  function changeStickFigureX(stickman)
	stickman.head.x += 1
	stickman.body.x += 1
	stickman.leftArm.x += 1
	stickman.rightArm.x += 1
	stickman.hip.x += 1
	stickman.leftLeg.x += 1
	stickman.rightLeg.x += 1

  end
  
  function changeStickFigureY(stickman)
	stickman.head.y += 1
	stickman.body.y += 1
	stickman.leftArm.y += 1
	stickman.rightArm.y += 1
	stickman.hip.y += 1
	stickman.leftLeg.y += 1
	stickman.rightLeg.y += 1
  end


local function resetTimer()
	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local function moveCoin()
	local randX = math.random(40, 360)
	local randY = math.random(40, 200)
	coinSprite:moveTo(randX, randY)
end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())
	local playerImage = gfx.image.new("images/player")
	playerSprite = gfx.sprite.new(playerImage)
	playerSprite:moveTo(200, 120)
	playerSprite:setCollideRect(0, 0, playerSprite:getSize())
	playerSprite:add()
	

	
	local coinImage = gfx.image.new("images/coin")
    coinSprite = gfx.sprite.new(coinImage)
	moveCoin()
	coinSprite:setCollideRect(0, 0, coinSprite:getSize())
	coinSprite:add()
	--#region

	local backgroundImage = gfx.image.new("images/background")
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			backgroundImage:draw(0, 0)
			gfx.clearClipRect()
		end
	)
	
	resetTimer()
end

initialize()

function playdate.update()
	if playTimer.value == 0 then
		if playdate.buttonJustPressed(playdate.kButtonA) then
			resetTimer()
			moveCoin()
			score = 0
		end
	else
		if playdate.buttonIsPressed(playdate.kButtonUp) then
			playerSprite:moveBy(0, -playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonRight) then
			playerSprite:moveBy(playerSpeed, 0)
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			playerSprite:moveBy(0, playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonLeft) then
			playerSprite:moveBy(-playerSpeed, 0)
		end

		local collisions = coinSprite:overlappingSprites()
		if #collisions >= 1 then
			moveCoin()
			score += 1
		end
	end
	playdate.timer.updateTimers()
	gfx.sprite.update()

	gfx.drawText("X: " .. stickFigure.head.x, 5, 5)
	gfx.drawText("Y: " .. stickFigure.head.y, 320, 5)
	--146, 116
	moveStickFigure(stickFigure)

end