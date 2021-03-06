﻿function courseplay:detachImplement(implementIndex)
	self.tools_dirty = true;
end

function courseplay:reset_tools(self)
	self.tippers = {}
	-- are there any tippers?
	self.tipper_attached = courseplay:update_tools(self, self)
	self.currentTrailerToFill = nil
	self.lastTrailerToFillDistance = nil
	self.tools_dirty = false;
end

function courseplay:isCombine(workTool)
	return (SpecializationUtil.hasSpecialization(Combine, workTool.specializations) or SpecializationUtil.hasSpecialization(AICombine, workTool.specializations)) and workTool.grainTankCapacity ~= nil and workTool.grainTankCapacity > 0;
end;
function courseplay:isChopper(workTool)
	return (SpecializationUtil.hasSpecialization(Combine, workTool.specializations) or SpecializationUtil.hasSpecialization(AICombine, workTool.specializations)) and workTool.grainTankCapacity ~= nil and workTool.grainTankCapacity == 0;
end;
function courseplay:isHarvesterSteerable(workTool)
	return workTool.typeName == "selfPropelledPotatoHarvester" or Utils.endsWith(workTool.configFileName, "grimmeMaxtron620.xml") or Utils.endsWith(workTool.configFileName, "grimmeTectron415.xml");
end;
function courseplay:isBaler(workTool) -- is the tool a baler?
	return (SpecializationUtil.hasSpecialization(Baler, workTool.specializations) or workTool.balerUnloadingState ~= nil);
end;
function courseplay:isRoundbaler(workTool) -- is the tool a roundbaler?
	return courseplay:isBaler(workTool) and workTool.baleCloseAnimationName ~= nil and workTool.baleUnloadAnimationName ~= nil;
end;
function courseplay:is_baleLoader(workTool) -- is the tool a bale loader?
	return (SpecializationUtil.hasSpecialization(baleLoader, workTool.specializations) or SpecializationUtil.hasSpecialization(BaleLoader, workTool.specializations) or (workTool.balesToLoad ~= nil and workTool.baleGrabber ~=nil and workTool.grabberIsMoving~= nil));
end;
function courseplay:isSprayer(workTool) -- is the tool a sprayer/spreader?
	return SpecializationUtil.hasSpecialization(Sprayer, workTool.specializations) or SpecializationUtil.hasSpecialization(sprayer, workTool.specializations) or courseplay:isSpecialSprayer(workTool)
end;
function courseplay:is_sowingMachine(workTool) -- is the tool a sowing machine?
	return (SpecializationUtil.hasSpecialization(sowingMachine, workTool.specializations) or SpecializationUtil.hasSpecialization(SowingMachine, workTool.specializations));
end;
function courseplay:isFoldable(workTool) --is the tool foldable?
	return SpecializationUtil.hasSpecialization(Foldable, workTool.specializations) or SpecializationUtil.hasSpecialization(foldable, workTool.specializations) or workTool.foldingParts ~= nil;
end;
function courseplay:isUBT(workTool) --is the tool a UBT?
	return SpecializationUtil.hasSpecialization(ubt, workTool.specializations) or SpecializationUtil.hasSpecialization(Ubt, workTool.specializations) or workTool.name == "UniversalBaleTrailer" or (workTool.numAttacherParts ~= nil and workTool.autoLoad ~= nil and workTool.loadingIsActive ~= nil and workTool.unloadLeft ~= nil and workTool.unloadRight ~= nil and workTool.unloadBack ~= nil and workTool.typeOnTrailer ~= nil);
end;
function courseplay:isMower(workTool)
	return SpecializationUtil.hasSpecialization(Mower, workTool.specializations) or Utils.endsWith(workTool.configFileName, "PoettingerAlpha.xml") or Utils.endsWith(workTool.configFileName, "PoettingerX8.xml");
end;
function courseplay:isBigM(workTool)
	return (SpecializationUtil.hasSpecialization(Steerable, workTool.specializations) or SpecializationUtil.hasSpecialization(steerable, workTool.specializations)) and courseplay:isMower(workTool);
end;
function courseplay:isAttachedCombine(workTool)
	return workTool.typeName == "attachableCombine" or (not SpecializationUtil.hasSpecialization(Steerable, workTool.specializations) and  workTool.grainTankCapacity ~= nil)
end;
function courseplay:isAttachedMixer(workTool)
	return workTool.typeName == "mixerWagon" or (not SpecializationUtil.hasSpecialization(Steerable, workTool.specializations) and  SpecializationUtil.hasSpecialization(MixerWagon, workTool.specializations))
end;
function courseplay:isMixer(workTool)
	return workTool.typeName == "selfPropelledMixerWagon" or (SpecializationUtil.hasSpecialization(Steerable, workTool.specializations) and  SpecializationUtil.hasSpecialization(MixerWagon, workTool.specializations))
end;
function courseplay:isFrontloader(workTool)
	return SpecializationUtil.hasSpecialization(Cylindered, workTool.specializations) and SpecializationUtil.hasSpecialization(AnimatedVehicle, workTool.specializations) and not SpecializationUtil.hasSpecialization(Shovel, workTool.specializations);
end;
function courseplay:isWheelloader(workTool)
	return workTool.typeName == "wheelLoader" or (SpecializationUtil.hasSpecialization(Steerable, workTool.specializations) and SpecializationUtil.hasSpecialization(Shovel, workTool.specializations) and SpecializationUtil.hasSpecialization(BunkerSiloCompacter, workTool.specializations));
end;

-- update implements to find attached tippers
function courseplay:update_tools(self, tractor_or_implement)
	--steerable (tractor, combine etc.)
	local tipper_attached = false
	if SpecializationUtil.hasSpecialization(AITractor, tractor_or_implement.specializations) 
	or courseplay:isHarvesterSteerable(tractor_or_implement) 
	or courseplay:isBigM(tractor_or_implement) 
	or courseplay:isMixer(tractor_or_implement)
	or courseplay:isWheelloader(tractor_or_implement)
	or tractor_or_implement.typeName == "frontloader" then
		local object = tractor_or_implement
		if self.ai_mode == 1 or self.ai_mode == 2 then
			-- if SpecializationUtil.hasSpecialization(Trailer, object.specializations) then
			if object.allowTipDischarge then
				tipper_attached = true
				table.insert(self.tippers, object)
			end
		elseif self.ai_mode == 3 then -- Overlader
			if SpecializationUtil.hasSpecialization(Trailer, object.specializations) then --to do
				tipper_attached = true
				table.insert(self.tippers, object)
			end
		elseif self.ai_mode == 4 then -- Fertilizer
			if courseplay:isSprayer(object) or courseplay:is_sowingMachine(object) then
				tipper_attached = true
				table.insert(self.tippers, object)
				courseplay:setMarkers(self, object)
				self.cp.noStopOnEdge = courseplay:isSprayer(object);
				self.cp.noStopOnTurn = courseplay:isSprayer(object);
			end
		elseif self.ai_mode == 6 then -- Baler, foragewagon, baleloader
			if courseplay:isBaler(object) 
			or courseplay:is_baleLoader(object) 
			or SpecializationUtil.hasSpecialization(Tedder, object.specializations) 
			or SpecializationUtil.hasSpecialization(Windrower, object.specializations) 
			or SpecializationUtil.hasSpecialization(Cultivator, object.specializations) 
			or SpecializationUtil.hasSpecialization(Plough, object.specializations)
			or SpecializationUtil.hasSpecialization(FruitPreparer, self.specializations) or SpecializationUtil.hasSpecialization(fruitPreparer, self.specializations) 
			or object.allowTipDischarge 
			or courseplay:isUBT(object) 
			or courseplay:isFoldable(object) then
				if courseplay:isUBT(object) and object.fillLevelMax ~= nil then
					self.cp.hasUBT = true;
					courseplay:debug(string.format("implement %s: setting UBT capacity to fillLevelMax (=%s)", tostring(object.name), tostring(object.fillLevelMax)), 3);
					object.capacity = object.fillLevelMax;
				end;
				tipper_attached = true;
				table.insert(self.tippers, object);
				courseplay:setMarkers(self, object);
				self.cp.noStopOnTurn = courseplay:isBaler(object) or courseplay:is_baleLoader(object) or courseplay:isUBT(object) or courseplay:isMower(object);
				self.cp.noStopOnEdge = courseplay:isBaler(object) or courseplay:is_baleLoader(object) or courseplay:isUBT(object);
			end
		elseif self.ai_mode == 8 then -- Liquid manure transfer
			--if SpecializationUtil.hasSpecialization(RefillTrigger, object.specializations) then
			tipper_attached = true
			table.insert(self.tippers, object)
			-- end
		elseif self.ai_mode == 9 then --Fill and empty shovel
			if courseplay:isWheelloader(tractor_or_implement) 
			or tractor_or_implement.typeName == "frontloader" 
			or courseplay:isMixer(tractor_or_implement) then
				tipper_attached = true;
				table.insert(self.tippers, object);
				object.cp.shovelState = 1
			end;
		end
	end

	if not self.cp.hasUBT then
		self.cp.hasUBT = false;
	end;
	-- go through all implements
	self.cpTrafficCollisionIgnoreList = {}
	self.cp.aiBackMarker = nil

	for k, implement in pairs(tractor_or_implement.attachedImplements) do
		local object = implement.object

		if object.cp == nil then --table for custom implement variables
			object.cp = {};
		end;

		if self.ai_mode == 1 or self.ai_mode == 2 then
			--	if SpecializationUtil.hasSpecialization(Trailer, object.specializations) then
			if object.allowTipDischarge then
				tipper_attached = true
				table.insert(self.tippers, object)
			end
		elseif self.ai_mode == 3 then -- Overlader
			if SpecializationUtil.hasSpecialization(Trailer, object.specializations) then --to do 
				tipper_attached = true
				table.insert(self.tippers, object)
			end
		elseif self.ai_mode == 4 then -- Fertilizer and Seeding
			if courseplay:isSprayer(object) or courseplay:is_sowingMachine(object) then
				tipper_attached = true
				table.insert(self.tippers, object)
				courseplay:setMarkers(self, object)
				self.cp.noStopOnEdge = courseplay:isSprayer(object);
				self.cp.noStopOnTurn = courseplay:isSprayer(object);
			end
		elseif self.ai_mode == 5 then -- Transfer
			if object.setPlane ~= nil then --open/close cover
				tipper_attached = true;
				table.insert(self.tippers, object);
			end;
		elseif self.ai_mode == 6 then -- Baler, foragewagon, baleloader
			if courseplay:isBaler(object) 
			or courseplay:is_baleLoader(object) 
			or SpecializationUtil.hasSpecialization(Tedder, object.specializations) 
			or SpecializationUtil.hasSpecialization(Windrower, object.specializations) 
			or SpecializationUtil.hasSpecialization(Cultivator, object.specializations) 
			or SpecializationUtil.hasSpecialization(Plough, object.specializations) 
			or SpecializationUtil.hasSpecialization(FruitPreparer, self.specializations) or SpecializationUtil.hasSpecialization(fruitPreparer, self.specializations) 
			or object.allowTipDischarge 
			or courseplay:isUBT(object) 
			or courseplay:isMower(object) 
			or courseplay:isFoldable(object) then
				if courseplay:isUBT(object) and object.fillLevelMax ~= nil then
					self.cp.hasUBT = true;
					courseplay:debug(string.format("implement %s: setting UBT capacity to fillLevelMax (=%s)", tostring(object.name), tostring(object.fillLevelMax)), 3);
					object.capacity = object.fillLevelMax;
				end;
				tipper_attached = true
				table.insert(self.tippers, object)
				courseplay:setMarkers(self, object)
				self.cp.noStopOnTurn = courseplay:isBaler(object) or courseplay:is_baleLoader(object) or courseplay:isUBT(object);
				self.cp.noStopOnEdge = courseplay:isBaler(object) or courseplay:is_baleLoader(object) or courseplay:isUBT(object);
			end;
		elseif self.ai_mode == 8 then --Liquid manure transfer
			--if SpecializationUtil.hasSpecialization(RefillTrigger, object.specializations) then
			tipper_attached = true
			table.insert(self.tippers, object)
			--		end
		elseif self.ai_mode == 9 then --Fill and empty shovel
			if courseplay:isFrontloader(object) or SpecializationUtil.hasSpecialization(Shovel, object.specializations) then 
				tipper_attached = true;
				table.insert(self.tippers, object);
				object.attacherVehicle.cp.shovelState = 1
			end
		end

		if object.aiLeftMarker ~= nil and object.aiForceTurnNoBackward == true then 
			self.cp.aiTurnNoBackward = true
		elseif object.aiLeftMarker == nil and table.getn(object.wheels) > 0 then
			self.cp.aiTurnNoBackward = true
		end
		courseplay:askForSpecialSettings(self,object)
		
		-- are there more tippers attached to the current implement?
		local other_tipper_attached
		if table.getn(object.attachedImplements) ~= 0 then
			other_tipper_attached = courseplay:update_tools(self, object)
		end
		if other_tipper_attached == true then
			tipper_attached = true
		end
		
		courseplay:debug(string.format("courseplay:update_tools() (%s)", tostring(self.name)), 2);

		courseplay:debug(tostring(object.name).." - adding to cpTrafficCollisionIgnoreList", 2)
		self.cpTrafficCollisionIgnoreList[object.rootNode] = true;
	end; --END for implement in attachedImplements
	
	for k,v in pairs(self.components) do
		self.cpTrafficCollisionIgnoreList[v.node] = true;
	end;

	--CUTTERS
	if self.attachedCutters ~= nil and table.getn(self.attachedImplements) ~= 0 then
		if self.numAttachedCutters ~= nil and self.numAttachedCutters > 0 then
			for cutter, implement in pairs(self.attachedCutters) do
				local object = implement.object
				if object ~= nil and object.cp == nil then
					object.cp = {};
				end;

				if self.ai_mode == 6 then
					tipper_attached = true;
					table.insert(self.tippers, object);
					courseplay:setMarkers(self, object)
					self.cpTrafficCollisionIgnoreList[object.rootNode] = true;
				end;
			end;
		end;
	end;
	
	if CPDebugLevel > 0 then
		print(string.format("%s cpTrafficCollisionIgnoreList", tostring(self.name)));
		for a,b in pairs(self.cpTrafficCollisionIgnoreList) do
			local name = g_currentMission.nodeToVehicle[a].name
			print(string.format("\\___ %s = %s", tostring(a), tostring(name)));
		end;
	end

	courseplay:getAutoTurnradius(self, tipper_attached);
	
	--tipreferencepoints 
	self.tipRefOffset = nil;
	if tipper_attached and self.tippers[1].rootNode ~= nil and self.tippers[1].tipReferencePoints ~= nil then
		local tipperX, tipperY, tipperZ = getWorldTranslation(self.tippers[1].rootNode);
		if tipper_attached and table.getn(self.tippers[1].tipReferencePoints) > 1 then
			for n=1 ,table.getn(self.tippers[1].tipReferencePoints) do
				local tipRefPointX, tipRefPointY, tipRefPointZ = worldToLocal(self.tippers[1].tipReferencePoints[n].node, tipperX, tipperY, tipperZ);
				tipRefPointX = math.abs(tipRefPointX);
				if tipRefPointX > 0.1 then
					self.tipRefOffset = tipRefPointX;
					break;
				else
					self.tipRefOffset = 0
				end;
			end;
		else 
			self.tipRefOffset = 0;
		end;
	end;


	--tippers with covers
	self.cp.tipperHasCover = false;
	self.cp.tippersWithCovers = nil;
	self.cp.tippersWithCovers = {};
	if tipper_attached then
		for i=1, table.getn(self.tippers) do
			local t = self.tippers[i];
			local coverItems = {};
			
			if t.configFileName ~= nil then
				local isHKD302 = t.configFileName == "data/vehicles/trailers/kroeger/HKD302.xml";
				local isMUK = t.configFileName == "data/vehicles/trailers/kroeger/MUK303.xml" or t.configFileName == "data/vehicles/trailers/kroeger/MUK402.xml";
				local isSRB35 = t.configFileName == "data/vehicles/trailers/kroeger/SRB35.xml";
				
				if isHKD302 then
					local c = getChild(t.rootNode, "bodyLeft");
					
					if c ~= nil and c ~= 0 then
						c = getChild(c, "bodyRight");
					end;
					if c ~= nil and c ~= 0 then
						c = getChild(c, "body");
					end;
					if c ~= nil and c ~= 0 then
						c = getChild(c, "plasticPlane");
					end;
					
					if c ~= nil and c ~= 0 then
						self.cp.tipperHasCover = true;
						table.insert(coverItems, c);
					end;
				elseif isMUK then
					local c = getChild(t.rootNode, "tank");
					
					if c ~= nil and c ~= 0 then
						c1 = getChild(c, "planeFlapLeft");
						c2 = getChild(c, "planeFlapRight");
					end;
					if c1 ~= nil and c1 ~= 0 and c2 ~= nil and c2 ~= 0  then
						self.cp.tipperHasCover = true;
						
						table.insert(coverItems, c1);
						table.insert(coverItems, c2);
					end;
				elseif isSRB35 then
					local c = getChild(t.rootNode, "plasticPlane");
					if c ~= nil and c ~= 0 then
						self.cp.tipperHasCover = true;
						
						table.insert(coverItems, c);
					end;
				end;
				
				if self.cp.tipperHasCover and table.getn(coverItems) > 0 then
					courseplay:debug(string.format("Implement \"%s\" has a cover (coverItems ~= nil)", tostring(t.name)), 3);
					local data = {
						tipperIndex = i,
						coverItems = coverItems
					};
					table.insert(self.cp.tippersWithCovers, data);
				end;
			end;
			
			if t.setPlane ~= nil or t.planeOpen ~= nil then
				courseplay:debug(string.format("Implement \"%s\" has a cover (setPlane ~= nil)", tostring(t.name)), 3);
				self.cp.tipperHasCover = true;
				local data = {
					tipperIndex = i
				};
				table.insert(self.cp.tippersWithCovers, data);
			end;
			
			if t.setCoverState ~= nil and t.cover ~= nil and t.cover.opened ~= nil and t.cover.closed ~= nil then
				courseplay:debug(string.format("Implement \"%s\" has a cover (setCoverState ~= nil)", tostring(t.name)), 3);
				self.cp.tipperHasCover = true;
				local data = {
					tipperIndex = i
				};
				table.insert(self.cp.tippersWithCovers, data);
			end;
		end;
	end;
	--courseplay:debug(tableShow(self.cp.tippersWithCovers, tostring(self.name) .. ": self.cp.tippersWithCovers"), 4);
	--END tippers with covers
	
	if tipper_attached then
		return true
	end
	return nil
end

function courseplay:setMarkers(self, object)
	object.cp.backMarkerOffset = nil
	object.cp.aiFrontMarker = nil
	-- get the behindest and the frontest  points :-) ( as offset to root node)
	local area = object.cuttingAreas
	if courseplay:isBigM(object) then
		area = object.mowerCutAreas
	elseif object.typeName == "defoliator_animated" then
		area = object.fruitPreparerAreas
	end

	local tableLength = table.getn(area)
	if tableLength == 0 then
		return
	end
	for k = 1, tableLength do
		for j,node in pairs(area[k]) do
			if j == "start" or j == "height" or j == "width" then 
				local x, y, z = getWorldTranslation(node)
				_, _, ztt = worldToLocal(self.rootNode, x, y, z)
				if object.cp.backMarkerOffset == nil or ztt > object.cp.backMarkerOffset then
					object.cp.backMarkerOffset = ztt
				end
				if object.cp.aiFrontMarker == nil  or ztt < object.cp.aiFrontMarker then
					object.cp.aiFrontMarker = ztt
				end
			end
		end
	end

	if self.cp.backMarkerOffset == nil or object.cp.backMarkerOffset < self.cp.backMarkerOffset then
		self.cp.backMarkerOffset = object.cp.backMarkerOffset
	end

	if object.isFuchsFass then
		local x,y,z = 0,0,0;
		local valveOffsetFromRootNode = 0;
		local caOffsetFromValve = -1.5; --4.5;

		if object.distributerIsAttached then
			x,y,z = getWorldTranslation(object.attachedImplements[1].object.rootNode);
		else
			x,y,z = getWorldTranslation(object.rootNode);
			valveOffsetFromRootNode = 3.5;
		end;

		local _, _, distToFuchs = worldToLocal(self.rootNode, x, y, z);
		self.cp.backMarkerOffset = distToFuchs + valveOffsetFromRootNode + caOffsetFromValve;
	end;

	if self.cp.aiFrontMarker == nil  or object.cp.aiFrontMarker > self.cp.aiFrontMarker then
		self.cp.aiFrontMarker = object.cp.aiFrontMarker
	end
	if self.cp.aiFrontMarker < -7 then
		self.cp.aiFrontMarker = -7
	end
	courseplay:debug("setMarkers: self.cp.backMarkerOffset: "..tostring(self.cp.backMarkerOffset).."  self.cp.aiFrontMarker: "..tostring(self.cp.aiFrontMarker),1)  
end

-- loads all tippers
function courseplay:load_tippers(self)
	local allowedToDrive = false
	local cx, cz = self.Waypoints[2].cx, self.Waypoints[2].cz
	local tipper_fill_level, tipper_capacity = self:getAttachedTrailersFillLevelAndCapacity()
	if tipper_fill_level == nil then tipper_fill_level = 0 end
	if tipper_capacity == nil then tipper_capacity = 0 end
	local fill_level = 0
	if tipper_capacity ~= 0 then
		fill_level = tipper_fill_level * 100 / tipper_capacity
	end

	if self.currentTrailerToFill == nil then
		self.currentTrailerToFill = 1
	end

	-- drive on when required fill level is reached
	local drive_on = false
	if self.timeout < self.timer or self.last_fill_level == nil then
		if self.last_fill_level ~= nil and fill_level == self.last_fill_level and fill_level > self.required_fill_level_for_drive_on then
			drive_on = true
		end
		self.last_fill_level = fill_level
		courseplay:set_timeout(self, 7000)
	end

	if fill_level == 100 or drive_on then
		self.last_fill_level = nil
		self.loaded = true
		self.lastTrailerToFillDistance = nil
		self.currentTrailerToFill = nil
		return true
	end

	if self.lastTrailerToFillDistance == nil then

		local current_tipper = self.tippers[self.currentTrailerToFill]

		-- drive on if actual tipper is full
		if current_tipper.fillLevel == current_tipper.capacity then
			if table.getn(self.tippers) > self.currentTrailerToFill then
				local tipper_x, tipper_y, tipper_z = getWorldTranslation(self.tippers[self.currentTrailerToFill].rootNode)

				self.lastTrailerToFillDistance = courseplay:distance(cx, cz, tipper_x, tipper_z)

				self.currentTrailerToFill = self.currentTrailerToFill + 1
			else
				self.currentTrailerToFill = nil
				self.lastTrailerToFillDistance = nil
			end
			allowedToDrive = true
		end

	else
		local tipper_x, tipper_y, tipper_z = getWorldTranslation(self.tippers[self.currentTrailerToFill].rootNode)

		local distance = courseplay:distance(cx, cz, tipper_x, tipper_z)

		if distance > self.lastTrailerToFillDistance and self.lastTrailerToFillDistance ~= nil then
			allowedToDrive = true
		else
			allowedToDrive = false
			local current_tipper = self.tippers[self.currentTrailerToFill]
			if current_tipper.fillLevel == current_tipper.capacity then
				if table.getn(self.tippers) > self.currentTrailerToFill then
					local tipper_x, tipper_y, tipper_z = getWorldTranslation(self.tippers[self.currentTrailerToFill].rootNode)
					self.lastTrailerToFillDistance = courseplay:distance(cx, cz, tipper_x, tipper_z)
					self.currentTrailerToFill = self.currentTrailerToFill + 1
				else
					self.currentTrailerToFill = nil
					self.lastTrailerToFillDistance = nil
				end
			end
		end
	end

	-- normal mode if all tippers are empty
	return allowedToDrive
end

-- unloads all tippers
function courseplay:unload_tippers(self)
	local allowedToDrive = true
	for k, tipper in pairs(self.tippers) do
		--if not tipper.allowsDetaching then
		if tipper.tipReferencePoints ~= nil then
			local numReferencePoints = table.getn(tipper.tipReferencePoints);
			local fruitType = tipper.currentFillType

			if self.currentTipTrigger.bunkerSilo ~= nil then
				
				local silos = table.getn(self.currentTipTrigger.bunkerSilo.movingPlanes)
				local x, y, z = getWorldTranslation(tipper.tipReferencePoints[1].node)
				local sx, sy, sz = worldToLocal(self.currentTipTrigger.bunkerSilo.movingPlanes[1].nodeId, x, y, z)
				local ex, ey, ez = worldToLocal(self.currentTipTrigger.bunkerSilo.movingPlanes[silos].nodeId, x, y, z)
				self.startentfernung =  Utils.vector2Length(sx, sz) 
				self.endentfernung = Utils.vector2Length(ex, ez)
				local laenge = courseplay:distance(sx, sz, ex, ez) 
				self.position = self.startentfernung*100/laenge
				self.gofortipping = false
				if self.runonce == nil then
					self.runonce = 0
				end
				self.filling1 = 0
				self.filling2 = 0
				self.filling3 = 0
				if self.runonce == 0 then
					if self.startentfernung < self.endentfernung then   --Richtungsentscheidung
						self.BGAdirection = 1   --vorwärts
					else	
						self.BGAdirection = 0   --rückwärts
					end
					for k = 1,silos,1 do
						local filling = self.currentTipTrigger.bunkerSilo.movingPlanes[k].fillLevel
						if k <= math.ceil(silos * 0.3) then
							self.filling1 =	self.filling1 + filling
						elseif k <= math.ceil(silos * 0.6) then
							self.filling2 =	self.filling2 + filling
						elseif k <= silos then 
							self.filling3 =	self.filling3 + filling
						end
					end;
					courseplay:debug(string.format("bga section 1: %f, bga section 3: %f, bga section 3: %f", self.filling1, self.filling2, self.filling3),1);
					
					if self.filling1 <= self.filling2 and self.filling1 < self.filling3 then
						self.tipLocation = 1
					elseif self.filling2 <= self.filling3 and self.filling2 < self.filling1 then
						self.tipLocation = 2
					elseif self.filling3 < self.filling1 and self.filling3 < self.filling2 then
						self.tipLocation = 3
					else
						self.tipLocation = 1
					end
					courseplay:debug(string.format("BGA tipLocation = %d", self.tipLocation),1);
					self.runonce = 1
				end
				if self.tipLocation == 1 then
					if self.position >= 0 and self.position <= 40 then
						self.gofortipping = true
					end
				elseif self.tipLocation == 2 then
					if self.position >= 30 and self.position <= 70 then
						self.gofortipping = true
					end
				elseif self.tipLocation == 3 then
					if self.position >= 60 then
						self.gofortipping = true
					end
				end
			else
				self.gofortipping = true
			end
			if self.currentTipTrigger.acceptedFillTypes[fruitType] and self.gofortipping == true then  
				if tipper.tipState == Trailer.TIPSTATE_CLOSED then
					if self.currentTipTrigger:getTipDistanceFromTrailer(tipper, tipper.currentTipReferencePointIndex)  == 0 or self.currentTipTrigger.bunkerSilo ~= nil then   --courtesy of Satis
						if self.toggledTipState < numReferencePoints then
							self.toggledTipState = self.toggledTipState +1
							tipper:toggleTipState(self.currentTipTrigger,self.toggledTipState);
							self.unloading_tipper = tipper
						else
							self.toggledTipState = 0
						end
					end
				elseif tipper.tipState ~= Trailer.TIPSTATE_CLOSING then 
					allowedToDrive = false
				end 
						
				if self.currentTipTrigger.bunkerSilo ~= nil then
					allowedToDrive = true
				end
			else
				courseplay:debug("trigger does not accept fruit or self.gofortipping = false(BGA) ", 1);
			end
		end
	end
	return allowedToDrive
end

function courseplay:getAutoTurnradius(self, tipper_attached)
	local sinAlpha = 0       --Sinus vom Lenkwinkel
	local wheelbase = 0      --Radstand
	local track = 0		 --Spurweite
	local turnRadius = 0     --Wendekreis unbereinigt
	local xerion = false
	if self.foundWheels == nil then
		self.foundWheels = {}
	end
	for i=1, table.getn(self.wheels) do
		local wheel =  self.wheels[i]
		if wheel.rotMax ~= 0 then
			if self.foundWheels[1] == nil then
				sinAlpha = wheel.rotMax
				self.foundWheels[1] = wheel
			elseif self.foundWheels[2] == nil then
				self.foundWheels[2] = wheel
			elseif self.foundWheels[4] == nil then
				self.foundWheels[4] = wheel
			end
		elseif self.foundWheels[3] == nil then
			self.foundWheels[3] = wheel
		end
	
	end
	if self.foundWheels[3] == nil then --Xerion and Co
		sinAlpha = sinAlpha *2
		xerion = true
	end
		
	if table.getn(self.foundWheels) == 3 or xerion then
		local wh1X, wh1Y, wh1Z = getWorldTranslation(self.foundWheels[1].driveNode);
		local wh2X, wh2Y, wh2Z = getWorldTranslation(self.foundWheels[2].driveNode);	
		local wh3X, wh3Y, wh3Z = 0,0,0
		if xerion then
			wh3X, wh3Y, wh3Z = getWorldTranslation(self.foundWheels[4].driveNode);
		else
			wh3X, wh3Y, wh3Z = getWorldTranslation(self.foundWheels[3].driveNode);
		end	 
		track  = courseplay:distance(wh1X, wh1Z, wh2X, wh2Z)
		wheelbase = courseplay:distance(wh1X, wh1Z, wh3X, wh3Z)
		turnRadius = 2*wheelbase/sinAlpha+track
		self.foundWheels = {}	
	else
		turnRadius = self.turn_radius                  -- Kasi and Co are not supported. Nobody does hauling with a Kasi or Quadtrack !!! 
	end;
	
	--if tipper_attached and self.ai_mode == 2 then
	if tipper_attached and (self.ai_mode == 2 or self.ai_mode == 3 or self.ai_mode == 4 or self.ai_mode == 6) then --JT: I've added modes 3, 4 & 6 - needed?
		self.autoTurnRadius = turnRadius;
		local n = table.getn(self.tippers);
		if (n == 1 and self.tippers[1].attacherVehicle ~= self) or (n > 1) then
			self.autoTurnRadius = turnRadius * 1.5;
		end;
	end;

	if self.turnRadiusAutoMode then
		self.turn_radius = self.autoTurnRadius;
		if math.abs(self.turn_radius) > 50 then
			self.turn_radius = 15
		end
	end;
end
