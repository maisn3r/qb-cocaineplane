Smuggle cocaine brick into the city by a plane to break it down onto small fractions for selling or usage.

**Features:**

- Rent a plane.
- Pick up cocaine brick package.
- Deliver & get cocaine brick.
- Process cocaine brick to get small coke baggys for use or sell.

Make sure you have these items on qb-core/shared.lua :

``["cokebaggy"] 					 = {["name"] = "cokebaggy", 			  	  	["label"] = "Bag of Coke", 				["weight"] = 0, 		["type"] = "item", 		["image"] = "cocaine_baggy.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "To get happy real quick."},``

``["coke_brick"] 		 			 = {["name"] = "coke_brick", 					["label"] = "Coke Brick", 				["weight"] = 1000, 		["type"] = "item", 		["image"] = "coke_brick.png", 			["unique"] = true, 		["useable"] = false, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "Heavy package of cocaine, mostly used for deals and takes a lot of space."},``


**Rewritten & optimized version of erractic_cokeruns for QBCore.**
