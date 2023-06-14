import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

local theBikeR = nil
local theBikeL = nil

local playerSprite = nil
local playerSpeed = 10

local firstEnemySprite = nil
local enemySpeed = 1

local headSize = 25

local firstEnemyX = 165
local firstEnemyY = 100

local secondEnemyX = 165
local secondEnemyY = 100

local thirdEnemyX = 165
local thirdEnemyY = 110

local playTimer = nil
local playTime = 30 * 1000

--local coinSprite = nil
--local score = 0

local firstEnemy = nil
local secondEnemy = nil
local thirdEnemy = nil

local moods = {"ANGRY!", "Irritated", "Dangerous!!!!!!", "Pacifist"}

local function resetTimer()
	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())
	local playerImage = gfx.image.new("images/broguy")
	--playerSprite = gfx.sprite.new(playerImage)
	--playerSprite:moveTo(50, 160)
	--playerSprite:setCollideRect(0, 0, playerSprite:getSize())
	--playerSprite:add()

	local bikeImageR = gfx.image.new("images/bike_r")
	local bikeImageL = gfx.image.new("images/bike_l")

	theBikeL = {sprite = gfx.sprite.new(bikeImageL), isDrawn = false, xSpeed = 0, ySpeed = 0}

	theBikeR = {sprite = gfx.sprite.new(bikeImageR), isDrawn = true, xSpeed = 0, ySpeed = 0}
	theBikeR.sprite:moveTo(100, 160)
	theBikeR.sprite:setCollideRect(0, 0, theBikeR.sprite:getSize())
	theBikeR.sprite:add()

	local enemyImage = gfx.image.new("images/enemy")
	local moodBubble = gfx.image.new("images/mood")

    firstEnemySprite = gfx.sprite.new(enemyImage)
	firstEnemySprite:setCollideRect(0, 0, firstEnemySprite:getSize())
	fTextSprite = gfx.sprite.new(moodBubble)
	firstEnemy = { sprite = firstEnemySprite, isCreated = false, flightDistance = 0, flightSpeed = 0, flightDirection = nil, isHit = false, x = firstEnemyX, y = firstEnemyY, speed = enemySpeed, xStoppingPoint = 200, bubble = {sprite = fTextSprite, x = firstEnemyX, y = firstEnemyY - headSize, text = moods[2]} }

	secondEnemySprite = gfx.sprite.new(enemyImage)
	secondEnemySprite:setCollideRect(0, 0, firstEnemySprite:getSize())
	sTextSprite = gfx.sprite.new(moodBubble)
	secondEnemy = { sprite = secondEnemySprite, isCreated = false, flightDistance = 0, flightSpeed = 0, flightDirection = nil, isHit = false, x = secondEnemyX, y = secondEnemyY, speed = enemySpeed, xStoppingPoint = 210, bubble = {sprite = sTextSprite, x = secondEnemyX, y = secondEnemyY - headSize, text = moods[1]} }

	thirdEnemySprite = gfx.sprite.new(enemyImage)
	thirdEnemySprite:setCollideRect(0, 0, firstEnemySprite:getSize())
	tTextSprite = gfx.sprite.new(moodBubble)
	thirdEnemy = { sprite = thirdEnemySprite, isCreated = false, flightDistance = 0, flightSpeed = 0, flightDirection = nil, isHit = false, x = thirdEnemyX, y = thirdEnemyY, speed = enemySpeed, xStoppingPoint = 220, bubble = {sprite = tTextSprite, x = thirdEnemyX, y = thirdEnemyY - headSize, text = moods[3]} }

	local backgroundImage = gfx.image.new("images/houses")
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

function getMoodText(num)
	return moods[math.random(table.getn(moods) - 1)]
	--return moods[num]
end

function spawnEnemy(enemy, criteria)
	if(criteria) then
		enemy.sprite:moveTo(enemy.x, enemy.y)
		enemy.sprite:add()
		enemy.bubble.sprite:moveTo(enemy.bubble.x, enemy.bubble.y)
		enemy.bubble.sprite:add()
		enemy.isCreated = true
	end
end

function checkAndStopBaddies(enemy)
	if(enemy.isCreated and enemy.x < enemy.xStoppingPoint and not enemy.isHit) then
		enemy.sprite:moveBy(enemy.speed, enemy.speed)
		enemy.x += enemy.speed
		enemy.y += enemy.speed
		enemy.bubble.x += enemy.speed
		enemy.bubble.y += enemy.speed		
		--gfx.drawText(enemy.bubble.text.text, enemy.bubble.text.x, enemy.bubble.text.y)
	end

	if enemy.flightDistance > 0  then
		if (enemy.flightDirection == "left") then
			enemy.x -= enemy.flightSpeed			
		else
			enemy.x += enemy.flightSpeed			
		end

		enemy.flightDistance -= enemy.flightSpeed
	end
end

function addText(enemy)
	if(enemy.isCreated) then
		gfx.drawTextInRect(enemy.bubble.text, enemy.bubble.x, enemy.bubble.y, 30, 50)
	end
end

function getEnemy(sprite)
	if sprite == firstEnemy.sprite then
		enemy = firstEnemy
	end

	if sprite == secondEnemy.sprite then
		enemy = secondEnemy
	end

	if sprite == thirdEnemy.sprite then
		enemy = thirdEnemy
	end

	return enemy
end

function playdate.update()
	-- if playTimer.value == 0 then
	-- 	if playdate.buttonJustPressed(playdate.kButtonA) then
	-- 		resetTimer()
	-- 		--moveCoin()
	-- 		score = 0
	-- 	end
	-- else
		if playdate.buttonIsPressed(playdate.kButtonUp) then
			if (theBikeL.isDrawn and theBikeL.sprite.y > 110) then
				theBikeL.xSpeed = 0
				theBikeL.ySpeed = playerSpeed
				theBikeL.sprite:moveBy(0, -playerSpeed)
			else
				if (theBikeR.sprite.y > 110) then
					theBikeR.xSpeed = 0
					theBikeR.ySpeed = playerSpeed
					theBikeR.sprite:moveBy(0, -playerSpeed)
				end
			end		
		end
		if playdate.buttonIsPressed(playdate.kButtonRight) then
			if (not theBikeR.isDrawn) then
				theBikeR.sprite:moveTo(theBikeL.sprite.x, theBikeL.sprite.y)
				theBikeR.sprite:setCollideRect(0, 0, theBikeR.sprite:getSize())
				theBikeR.sprite:add()
				theBikeL.isDrawn = false
				theBikeR.isDrawn = true
				theBikeL.sprite:remove()
			else
				theBikeR.xSpeed = playerSpeed
				theBikeR.ySpeed = 0
				theBikeR.sprite:moveBy(playerSpeed, 0)
			end				
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			if (theBikeL.isDrawn) then
				theBikeL.sprite:moveBy(0, playerSpeed)
				theBikeL.xSpeed = 0
				theBikeL.ySpeed = playerSpeed
			else
				theBikeR.sprite:moveBy(0, playerSpeed)
				theBikeR.xSpeed = 0
				theBikeR.ySpeed = playerSpeed
			end
		end
		if playdate.buttonIsPressed(playdate.kButtonLeft) then
			--theBike:moveBy(-playerSpeed, 0)
			if (not theBikeL.isDrawn) then			
				theBikeL.sprite:moveTo(theBikeR.sprite.x, theBikeR.sprite.y)
				theBikeL.sprite:setCollideRect(0, 0, theBikeL.sprite:getSize())
				theBikeL.sprite:add()
				theBikeL.isDrawn = true
				theBikeR.isDrawn = false
				theBikeR.sprite:remove()
			else
				if (theBikeL.sprite.x > 40) then
					theBikeL.sprite:moveBy(-playerSpeed, 0)
					theBikeL.xSpeed = playerSpeed
					theBikeL.ySpeed = 0
				else
					theBikeL.xSpeed = playerSpeed
					theBikeL.ySpeed = 0			
				end
			end
		end

		local collisionsR = theBikeR.sprite:overlappingSprites()
		local collisionsL = theBikeL.sprite:overlappingSprites()

		if (#collisionsR > 0) then
			for i=1, #collisionsR do
				local enemy = getEnemy(collisionsR[i])

				if (not enemy.isHit) then
					-- enemy.sprite:moveBy(theBikeR.xSpeed * 1.5, theBikeR.ySpeed * 1.01)
					enemy.flightDistance = theBikeR.xSpeed * 10
					enemy.flightSpeed = 12
					enemy.flightDirection = "right"
					--enemy.x += (theBikeR.xSpeed * 1.5)
					--enemy.y += (theBikeR.ySpeed * )
					enemy.bubble.sprite:remove()
					enemy.isHit = true
				end
				
				-- s.x += (theBikeR.xSpeed * 1.5)
				-- s.y += (theBikeR.ySpeed * 1.01)			
			end
		end

		if #collisionsL > 0 then
			for i=1, #collisionsL do
				local enemy = getEnemy(collisionsL[i])

				if (not enemy.isHit) then
					enemy.flightDistance = theBikeR.xSpeed * 10
					enemy.flightSpeed = 12
					enemy.flightDirection = "left"
					enemy.bubble.sprite:remove()
					enemy.isHit = true
				end
				
				-- s.x += (-theBikeL.xSpeed * 1.5)
				-- s.y += theBikeL.ySpeed * 1.01
			end
		end
		--if #collisions >= 1 then
			--moveCoin()
			--score += 1
		--end

		--this is just using the timer.  we can make some criteria based 
		-- off of CRANKING THAT HOG
		firstEnemyCriteria = playTimer.value / 1000 < 25;
		spawnEnemy(firstEnemy, firstEnemyCriteria)

		secondEnemyCriteria = playTimer.value / 1000 < 20;
		spawnEnemy(secondEnemy, secondEnemyCriteria)

		thirdEnemyCriteria = playTimer.value / 1000 < 15;
		spawnEnemy(thirdEnemy, thirdEnemyCriteria)

		checkAndStopBaddies(firstEnemy)
		checkAndStopBaddies(secondEnemy)
		checkAndStopBaddies(thirdEnemy)
	--end

	playdate.timer.updateTimers()
	gfx.sprite.update()
	--addText(firstEnemy)
	--addText(secondEnemy)
	--addText(thirdEnemy)
	if (theBikeL.isDrawn) then
		gfx.drawText("X: " .. theBikeL.sprite.x, 5, 5)
		gfx.drawText("Y: " .. theBikeL.sprite.y, 320, 5)
	else
		gfx.drawText("X: " .. theBikeR.sprite.x, 5, 5)
		gfx.drawText("Y: " .. theBikeR.sprite.y, 320, 5)
	end
	--gfx.drawText("Time: " .. math.ceil(playTimer.value/1000), 35, 5)
end