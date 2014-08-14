----------------------------------------------------------------------------------
--
-- mainscene.lua
--
----------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require("widget")
local scene = composer.newScene()


function scene:create( event )
	local group = self.view
   
end

function scene:show( event )
	local group = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
			-- e.g. start timers, begin animation, play audio, etc.
		local locationNumber = 1  --a counter to display on location labels
		local currentLocation, currentLatitude, currentLongitude

		local outline = display.newRect( 16, 16, 550, 900 )
		outline.x = display.contentCenterX
		outline.y = display.contentCenterY
		outline:setFillColor( 1, 1, 1, 0.2 )

		if ( system.getInfo( "environment" ) == "simulator" ) then

		    local simulatorMessage = "Maps not supported in Corona Simulator.\nYou must build for iOS or Android to test native.newMapView() support."
		    local label = display.newText( simulatorMessage, 36, 40, 270, 0, native.systemFont, 25 )
		    label.anchorX = 0
		    label.anchorY = 0
		end

		local myMap = native.newMapView( 20, 20, 550, 900 )

		if ( myMap ) then
		    -- Display a normal map with vector drawings of the streets.
		    -- Other mapType options are "satellite" and "hybrid".
		    myMap.mapType = "normal"

		    myMap.x = display.contentCenterX
		    myMap.y = display.contentCenterY

		    -- Initialize map to a real location, since default location (0,0) is not very interesting
		    myMap:setCenter( 37.331692, -122.030456 )

		    -- This is returned as a mapLocation event
		    local function mapLocationListener(event)
		        print("map tapped latitude: ", event.latitude)
		        print("map tapped longitude: ", event.longitude)
		    end
		    myMap:addEventListener("mapLocation", mapLocationListener)
		end
		-- A function to handle the "mapAddress" event (also known as "reverse geocoding", ie: coordinates -> string).
		local function mapAddressHandler( event )
		    if ( event.isError ) then
		        -- Failed to receive location information.
		        native.showAlert( "Error", event.errorMessage, { "OK" } )
		    else
		        -- Location information received... display it.
		        local locationText =
		            "Latitude: " .. currentLatitude .. 
		            ", Longitude: " .. currentLongitude ..
		            ", Address: " .. ( event.streetDetail or "" ) ..
		            " " .. ( event.street or "" ) ..
		            ", " .. ( event.city or "" ) ..
		            ", " .. ( event.region or "" ) ..
		            ", " .. ( event.country or "" ) ..
		            ", " .. ( event.postalCode or "" )

		        native.showAlert( "You Are Here", locationText, { "OK" } )
		    end
		end

		-- A function to handle the "mapLocation" event (also known as "forward geocoding", ie: string -> coordinates).
		local mapLocationHandler = function( event )
		    if event.isError then
		        -- Location name not found.
		        native.showAlert( "Error", event.errorMessage, { "OK" } )
		    else
		        -- Move map so this location is at the center
		        -- (The final parameter toggles map animation, which may not be visible if moving a large distance)
		        myMap:setCenter( event.latitude, event.longitude, true )

		        -- Add a pin to the map at the new location
		        markerTitle = "Location " .. locationNumber
		        locationNumber = locationNumber + 1
		        myMap:addMarker( event.latitude, event.longitude, { title=markerTitle, subtitle=inputField.text } )
		    end
		end


		local buttonRelease = function( event )
		    -- Do not continue if a MapView has not been created.
		    if ( myMap == nil ) then
		        return
		    end

		    -- Fetch the user's current location
		    currentLocation = myMap:getUserLocation()
		    if currentLocation.errorCode then
		        -- Current location is unknown if the "errorCode" property is not nil.
		        currentLatitude = 0
		        currentLongitude = 0
		        native.showAlert( "Error", currentLocation.errorMessage, { "OK" } )
		    else
		        -- Current location data was received.
		        -- Move map so that current location is at the center.
		        currentLatitude = currentLocation.latitude
		        currentLongitude = currentLocation.longitude
		        myMap:setRegion( currentLatitude, currentLongitude, 0.01, 0.01, true )

		        -- Look up nearest address to this location (this is returned as a "mapAddress" event, handled above)
		        myMap:nearestAddress( currentLatitude, currentLongitude, mapAddressHandler )
		    end
		end


		local button = widget.newButton
		{
		    label = "Get Current Location",
		    onRelease = buttonRelease
		}
		button.x = display.contentCenterX
		button.y = 30
	end	
end

function scene:hide( event )
	local group = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
		-- composer.prevScene = composer.getSceneName("current")
	end	
end


function scene:destroy( event )
	local group = self.view
	
	group:removeSelf( )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene