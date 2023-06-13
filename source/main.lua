import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

local playerSprite = nil
local playerSpeed = 4

local firstEnemySprite = nil
local enemySpeed = 1

local firstEnemyX = 100
local firstEnemyY = 100

local secondEnemyX = 120
local secondEnemyY = 100

local thirdEnemyX = 135
local thirdEnemyY = 110

local playTimer = nil
local playTime = 30 * 1000

--local coinSprite = nil
--local score = 0

local firstEnemy = nil
local secondEnemy = nil
local thirdEnemy = nil


local function resetTimer()
	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())
	local playerImage = gfx.image.new("images/player")
	playerSprite = gfx.sprite.new(playerImage)
	playerSprite:moveTo(50, 160)
	playerSprite:setCollideRect(0, 0, playerSprite:getSize())
	playerSprite:add()

	local enemyImage = gfx.image.new("images/enemy")
    firstEnemySprite = gfx.sprite.new(enemyImage)
	firstEnemySprite:setCollideRect(0, 0, firstEnemySprite:getSize())
	firstEnemy = { sprite = firstEnemySprite, isCreated = false, x = firstEnemyX, y = firstEnemyY, speed = enemySpeed, xStoppingPoint = 152 }

	secondEnemySprite = gfx.sprite.new(enemyImage)
	secondEnemySprite:setCollideRect(0, 0, firstEnemySprite:getSize())
	secondEnemy = { sprite = secondEnemySprite, isCreated = false, x = secondEnemyX, y = secondEnemyY, speed = enemySpeed, xStoppingPoint = 174 }

	thirdEnemySprite = gfx.sprite.new(enemyImage)
	thirdEnemySprite:setCollideRect(0, 0, firstEnemySprite:getSize())
	thirdEnemy = { sprite = thirdEnemySprite, isCreated = false, x = thirdEnemyX, y = thirdEnemyY, speed = enemySpeed, xStoppingPoint = 190 }

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

function spawnEnemy(enemy, criteria)
	if(criteria) then
		enemy.sprite:moveTo(enemy.x, enemy.y)
		enemy.sprite:add()
		enemy.isCreated = true
	end
end

function checkAndStopBaddies(enemy)
	if(enemy.isCreated and enemy.x < enemy.xStoppingPoint) then
		enemy.sprite:moveBy(enemy.speed, enemy.speed)
		enemy.x += enemy.speed
		enemy.y += enemy.speed
	end
end

function playdate.update()
	if playTimer.value == 0 then
		if playdate.buttonJustPressed(playdate.kButtonA) then
			resetTimer()
			--moveCoin()
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

		local collisions = firstEnemySprite:overlappingSprites()
		--if #collisions >= 1 then
			--moveCoin()
			--score += 1
		--end

		--this is just using the play clock.  we can make some criteria based 
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
	end

	playdate.timer.updateTimers()
	gfx.sprite.update()
	gfx.drawText("X: " .. firstEnemyX, 5, 5)
	gfx.drawText("Y: " .. firstEnemyY, 320, 5)
	gfx.drawText("Time: " .. math.ceil(playTimer.value/1000), 35, 5)
end