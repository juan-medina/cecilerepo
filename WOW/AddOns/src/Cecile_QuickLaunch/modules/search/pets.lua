----------------------------------------------------------------------------------------------------
-- search pets module

--get the engine and create the module
local Engine = select(2,...);

--create the modules as submodule of search
local search = Engine.AddOn:GetModule("search");
local mod = search:NewModule("pets");


--get the locale
local L=Engine.Locale;

--debug
local debug = Engine.AddOn:GetModule("debug");

--module defaults
mod.Defaults = {
	profile = {
		favorites = true,
		noFavorites = true,
		token = L["PETS_PET"],
		favoriteTag = L["PETS_FAVORITE"],
	},
};

--module options table
mod.Options = {
	order = 4,
	type = "group",
	name = L["PETS_MODULE"],
	cmdInline = true,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["SEARCH_ENABLE_MODULE"],
			desc = L["SEARCH_ENABLE_MODULE_DESC"],
			get = function()
				return mod:IsEnabled();
			end,
			set = function(key, value)

				if(value) then
					mod:Enable();
				else
					mod:Disable();
				end

				Engine.Profile.search.disableModules[mod:GetName()] = (not value);

			end,
		},
		favorites = {
			order = 2,
			type = "toggle",
			name = L["PETS_RETURN_FAVORITES"],
			desc = L["PETS_RETURN_FAVORITES_DESC"],
			get = function()
				return Engine.Profile.search.pets.favorites;
			end,
			set = function(key, value)
				Engine.Profile.search.pets.favorites = value;
			end,
			disabled = function()
				return not mod:IsEnabled();
			end,
		},
		noFavorites = {
			order = 4,
			type = "toggle",
			name = L["PETS_RETURN_NO_FAVORITES"],
			desc = L["PETS_RETURN_NO_FAVORITES_DESC"],
			get = function()
				return Engine.Profile.search.pets.noFavorites;
			end,
			set = function(key, value)
				Engine.Profile.search.pets.noFavorites = value;
			end,
			disabled = function()
				return not mod:IsEnabled();
			end,
		},
		token = {
			order = 5,
			type = "input",
			name = L["SEARCH_TOKEN"],
			desc = L["SEARCH_TOKEN_DESC"],
			get = function()
				return Engine.Profile.search.pets.token;
			end,
			set = function(key, value)
				if not (value=="") then
					Engine.Profile.search.pets.token = value;
				end
			end,
			disabled = function()
				return not mod:IsEnabled();
			end,
		},
		favoriteTag = {
			order = 6,
			type = "input",
			name = L["PETS_FAVORITE_TAG"],
			desc = L["PETS_FAVORITE_TAG_DESC"],
			get = function()
				return Engine.Profile.search.pets.favoriteTag;
			end,
			set = function(key, value)
				if not (value=="") then
					Engine.Profile.search.pets.favoriteTag = value;
				end
			end,
			disabled = function()
				return not mod:IsEnabled();
			end,
		},
	}

};

--initialize the module
function mod:OnInitialize()

	--we dont have items
	mod.items = {};

	--get the window module
	mod.window = Engine.AddOn:GetModule("window");

	debug("search/pets module initialize");

	mod.desc = L["PETS_MODULE"];
end

--summon a pet if item.data.id==0 its random
function mod.summonPet(item)

	--notify window
	mod.window.OnButtonClick(item);

	--check if its summon normal o random (favorite)
	if(item.data.id==0) then
		C_PetJournal.SummonRandomPet(false);
	else
		C_PetJournal.SummonPetByGUID(item.data.id);
	end

end

--populate the list
function mod:PopulatePets()

	--lcoal vars
	local index,item,creatureName;

	--options
	local token = Engine.Profile.search.pets.token;
	local favorites = Engine.Profile.search.pets.favorites;
	local noFavorites = Engine.Profile.search.pets.noFavorites;
	local favoriteTag = Engine.Profile.search.pets.favoriteTag;

	--get number of pets
	local numPets = C_PetJournal.GetNumPets();

	--for formating the text
	local searchableText = "";

	--loop the pets
	for index = 1, numPets do
		local petID, speciesID, owned, customName, level, isFavorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(index)

		--if we own the pet
		if owned then


			searchableText = nil;

			creatureName = speciesName .. (customName and ( " [" .. customName .. "]" ) or "");

			if isFavorite and favorites then

				searchableText = token .. ": " .. creatureName .. " (".. favoriteTag .. ")";

			elseif noFavorites then

				searchableText = token .. ": " .. creatureName;

			end

			if searchableText then

				--add the text and function
	    		item = { text = searchableText , id=petID, func = mod.summonPet; };

	    		--insert the result
	    		table.insert(mod.items,item);

	    	end

		end

	end

	--get the GUID for summoned pet
	local summonedPetGUID = C_PetJournal.GetSummonedPetGUID();

	--add a random favorite pet on top
	searchableText = token .. ": " .. L["PETS_RANDOM"] .. " (".. favoriteTag .. ")";
    item = { text = searchableText , id=0, func = mod.summonPet; };
    table.insert(mod.items,1,item);

	--if we have a pet sumoned create a search for dismiss
	if not (summonedPetGUID  == nil) then

		--create the text
		searchableText = token .. ": " .. L["PETS_DISMISS"];

		--set the text and function, we calling again to summon will dismm it
    	item = { text = searchableText , id=summonedPetGUID, func = mod.summonPet; };
    	table.insert(mod.items,1,item);

	end

end

--refresh the data
function mod:Refresh()

	debug("refreshing pet data");

	--clear items
	mod.items = {};

	--populate the data
	mod:PopulatePets();

	debug("data refreshed");

end

--enable module
function mod:OnEnable()

	--we dont have items
	mod.items = {};

	debug(mod:GetName().." Enabled");

end

--disabled module
function mod:OnDisable()

	--clear items
	mod.items = {};

	debug(mod:GetName().." Disabled");
end