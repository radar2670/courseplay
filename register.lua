SpecializationUtil.registerSpecialization("courseplay", "courseplay", g_modsDirectory .. "/ZZZ_courseplay/courseplay.lua")
SpecializationUtil.registerSpecialization("autoovercharge", "AutoOvercharge", g_modsDirectory .. "/ZZZ_courseplay/AutoOvercharge.lua")
SpecializationUtil.registerSpecialization("perard", "perard", g_modsDirectory .. "/ZZZ_courseplay/AutoOvercharge.lua")


-- adding courseplay to default vehicles and vehicles that are loaded after courseplay in multiplayer
-- thanks to donner!

function register_courseplay()
	for k, v in pairs(VehicleTypeUtil.vehicleTypes) do
		if v ~= nil then
			if v.name == "perard.perard" then
				--courseplay:debug("renew perard interbenne 25", 2);
				for l, w in pairs(v.specializations) do
					v.specializations[l] = nil
				end
				table.insert(v.specializations, SpecializationUtil.getSpecialization("fillable"));
				table.insert(v.specializations, SpecializationUtil.getSpecialization("attachable"));
				table.insert(v.specializations, SpecializationUtil.getSpecialization("trailer"));
				table.insert(v.specializations, SpecializationUtil.getSpecialization("perard"));
			else
				for a = 1, table.maxn(v.specializations) do
					local s = v.specializations[a];
					if s ~= nil then
						if s == SpecializationUtil.getSpecialization("steerable") then
							if not SpecializationUtil.hasSpecialization(courseplay, v.specializations) then
								--courseplay:debug("adding courseplay to:"..tostring(v.name), 3);
								table.insert(v.specializations, SpecializationUtil.getSpecialization("courseplay"));
							end
						end;
						if s == SpecializationUtil.getSpecialization("fillable") then
							if not SpecializationUtil.hasSpecialization(autoovercharge, v.specializations) then
								--courseplay:debug("adding autoovercharge to:"..tostring(v.name), 3);
								table.insert(v.specializations, SpecializationUtil.getSpecialization("autoovercharge"));
							end
						end
					end;
				end;
			end;
		end;
	end;
end


-- dirty workaround for localization - don't try this at home!
-- get all l10n > text > #name attribues from modDesc.xml, insert them into courseplay.locales
function cp_setLocales()
	courseplay.locales = {};
	if not Utils.endsWith(courseplay_path, "/") then
		courseplay_path = courseplay_path .. "/";
	end;
	local cp_modDesc_file = loadXMLFile("cp_modDesc", courseplay_path .. "modDesc.xml");
	local b=0;
	while true do
		local attr = string.format("modDesc.l10n.text(%d)#name", b);
		local textName = getXMLString(cp_modDesc_file, attr);
		if textName ~= nil then
			if not g_i18n:hasText(textName) then
				g_i18n:setText(textName, textName);
			end;
			courseplay.locales[textName] = g_i18n:getText(textName);
			--print(string.format("courseplay.locales[%s] (#%d) = %s", textName, b, courseplay.locales[textName]));
			b = b + 1;
		else
			break;
		end;
	end;
end;

function cp_setupHud()
	courseplay.numAiModes = 9;
	courseplay.hud = {
		infoBasePosX = 0.433;
		infoBasePosY = 0.002;
		infoBaseWidth = 0.512; --try: 512/1920
		infoBaseHeight = 0.512; --try: 512/1080
		infoBaseCenter = 0.433 + 0.16;
		visibleArea = {
			x1 = 0.433;
			x2 = 0.753;
			y1 = 0.002;
			y2 = 0.30463; --0.002 + 0.271 + 32/1080 + 0.002;
		};
		linesPosY = {};
		linesBottomPosY = {};
		linesButtonPosY = {};
		numPages = 9,
		numLines = 6;
		lineHeight = 0.021;
		colors = {
			white =         {       1,       1,       1, 1    };
			whiteInactive = {       1,       1,       1, 0.75 };
			whiteDisabled = {       1,       1,       1, 0.15 };
			hover =         {  32/255, 168/255, 219/255, 1    };
			activeGreen =   { 110/255, 235/255,  56/255, 1    };
			activeRed =     { 206/255,  83/255,  77/255, 1    };
			closeRed =      { 180/255,       0,       0, 1    };
		};
		clickSound = createSample("clickSound");
		pagesPerMode = {
			--Pg 0  Pg 1  Pg 2  Pg 3   Pg 4   Pg 5  Pg 6  Pg 7  Pg 8   Pg 9
			{ true, true, true, true,  false, true, true, true, false, false }; --Mode 1
			{ true, true, true, true,  true,  true, true, true, false, false }; --Mode 2
			{ true, true, true, true,  true,  true, true, true, false, false }; --Mode 3
			{ true, true, true, false, false, true, true, true, true,  false }; --Mode 4
			{ true, true, true, false, false, true, true, true, false, false }; --Mode 5
			{ true, true, true, false, false, true, true, true, true,  false }; --Mode 6
			{ true, true, true, true,  false, true, true, true, false, false }; --Mode 7
			{ true, true, true, true,  false, true, true, true, false, false }; --Mode 8
			{ true, true, true, false, false, true, true, true, false, true  }; --Mode 9
		};
	};
	loadSample(courseplay.hud.clickSound, Utils.getFilename("sounds/cpClickSound.wav", courseplay_path), false);
	
	for l=1,courseplay.hud.numLines do
		if l == 1 then
			courseplay.hud.linesPosY[l] = courseplay.hud.infoBasePosY + 0.210;
			courseplay.hud.linesBottomPosY[l] = courseplay.hud.infoBasePosY + 0.077;
		else
			courseplay.hud.linesPosY[l] = courseplay.hud.linesPosY[1] - ((l-1) * courseplay.hud.lineHeight);
			courseplay.hud.linesBottomPosY[l] = courseplay.hud.linesBottomPosY[1] - ((l-1) * courseplay.hud.lineHeight);
		end;
		courseplay.hud.linesButtonPosY[l] = courseplay.hud.linesPosY[l] + 0.0020; --0.0045
	end;
	
end;

cp_setupHud();
cp_setLocales();
register_courseplay();

