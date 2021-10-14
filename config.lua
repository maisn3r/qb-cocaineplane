Config = {}

Config.doorHeading = 215.52 -- change this to the proper heading to look at the door you start the runs with
Config.price = 1000 -- amount you have to pay to start a run 
Config.cokeTime = 60000 -- time in ms the effects of coke will last for
Config.randBrick = math.random(7,10) -- change the numbers to how much coke you want players to receive after breaking down bricks
Config.takeBrick = 1 -- amount of brick you want to take after processing

Config.locations = {
	[1] = { 
		fuel = {x = 4508.69, y = -4509.32, z = 4.84}, -- location of the jerry can/waypoint
		landingLoc = {x = 1743.822, y = 3258.627, z = 41.36734}, -- don't mess with this unless you know what you're doing
		plane = {x = 736.6801, y = 2973.17, z = 93.81644, h = 284.13}, -- don't mess with this unless you know what you're doing
		fuselage = {x = 1729.039, y = 3311.423, z = 41.2235}, -- location of the 3D text to fuel the plane
		stationary = {x = 1730.208, y = 3315.586, z = 41.22352, h = 16.29}, -- location of the plane if Config.landPlane is false 
		delivery = {x = 2916.86, y = 1476.89, z = -0.43}, -- delivery location vector3(2916.86, 1476.89, -0.43)
		hangar = {x = 4508.69, y = -4509.32, z = 4.84}, -- end location
		parking = {x = 4508.69, y = -4509.32, z = 4.84, h = 23.31}, -- vector4(4508.69, -4509.32, 4.84, 23.31)											
	},
}
