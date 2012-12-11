if not IsAddOnLoaded( "ElvUI" )  then return end
if not IsAddOnLoaded( "Skada" )  then return end
if not IsAddOnLoaded( "ElvUI_MeterOverlay" )  then return end

local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

	local Skada = _G.Skada		
	
	function skadaToggle()
		Skada:ToggleWindow()
	end
			
	function skadaGetSumtable(tablename, mode)

		local totalsum=0
		local totalpersec=0
		
		local sumtable = {}
			
		if(tablename=="CurrentFightData") then
			report_set = Skada.current
		elseif(tablename=="LastFightData") then
			report_set = Skada.last
		elseif(tablename=="OverallData") then
			report_set = Skada.total
		else
			report_set = nil
		end
				
		if(report_set) then		
						
			-- For each item in dataset
			local nr = 1
			local templable = {}
			
			for i, player in ipairs(report_set.players) do
				if player.id then			
				
					templable = {}
					
					templable = {enclass=player.class,name=player.name,damage=player.damage,healing=player.healing,dps=0,hps=0}						
					
					--templable.healing = templable.healing+player.totalabsorbs					
					
					local totaltime = Skada:PlayerActiveTime(report_set, player)
					
					if (mode=="DPS") then
						if (templable.damage>0) then
							templable.dps = templable.damage / math.max(1,totaltime)												
							totalsum = totalsum + templable.damage
							totalpersec = totalpersec + templable.dps	
							table.insert(sumtable,templable)
						end
					else
						if (templable.healing>0) then
							templable.hps = templable.healing / math.max(1,totaltime)
						
							totalsum = totalsum + templable.healing
							totalpersec = totalpersec + templable.hps			
							table.insert(sumtable,templable)
						end
					end																												
				end
			end		
			if (mode=="DPS") then
				table.sort(sumtable, function(a,b) return a.damage > b.damage end)
			else
				table.sort(sumtable, function(a,b) return a.healing > b.healing end)
			end
		end						
		
		return sumtable, totalsum, totalpersec
	end		
	
	function skadaGetRaidValuePerSecond(tablename, mode)
	
		local mydps = 0		
		local totalpersec=0
		
		if(tablename=="CurrentFightData") then
			report_set = Skada.current
		elseif(tablename=="LastFightData") then
			report_set = Skada.last
		elseif(tablename=="OverallData") then
			report_set = Skada.total
		else
			report_set = nil
		end
				
		if(report_set) then		
						
			-- For each item in dataset
			for i, player in ipairs(report_set.players) do
				if player.id then			
													
					local totaltime = Skada:PlayerActiveTime(report_set, player)
					local dps = 0
					local hps = 0
					
					if (mode=="DPS") then
						if (player.damage>0) then
							dps = player.damage / math.max(1,totaltime)
						end						
						totalpersec = totalpersec + dps			
					else
						local realhealing = player.healing --+ player.totalabsorbs
						
						if (realhealing>0) then
							hps = realhealing / math.max(1,totaltime)
						end															
						totalpersec = totalpersec + hps			
					end																						
					if E.myname == player.name then	
						if (mode=="DPS") then					
							mydps = dps
						else
							mydps = hps
						end
					end					
				end
			end		
		end				
		
		return totalpersec,mydps
	end	
	
	EMO.desc = "Skada Overlay"
	EMO.toggle = skadaToggle	
	EMO.getRaidValuePerSecond = skadaGetRaidValuePerSecond
	EMO.getSumtable = skadaGetSumtable	