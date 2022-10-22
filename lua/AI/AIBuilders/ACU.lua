local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local HaveLessThanFiveT2LandFactoryACU = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.LAND * categories.TECH2, false, true )) >= 5 then
        return 0, false
	end
	
	return self.Priority,true
end

local HaveLessThanThreeT2AirFactoryACU = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.AIR * categories.TECH2, false, true )) >= 3 then
        return 0, false
	end
	
	return self.Priority,true
end


BuilderGroup { BuilderGroupName = 'Swarm ACU Initial Opener',
    BuildersType = 'EngineerBuilder',    
    Builder {
        BuilderName = 'Swarm Commander First Factory',
        PlatoonTemplate = 'CommanderBuilderSwarm',
        Priority = 5000,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
        },
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            BuildClose = false,
            Construction = {
                AdjacencyBias = 'ForwardClose',
                AdjacencyPriority = {
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Intial Mexes',
        PlatoonTemplate = 'CommanderBuilderSwarm',
        Priority = 4900,
        BuilderConditions = {
            { MABC, 'CanBuildOnMassDistanceSwarm', { 'LocationType', 0, 12, nil, nil, 0, 'AntiSurface', 1}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.MASSEXTRACTION }},
        },
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                    'T1Resource',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SC ACU Formers',                                    
    BuildersType = 'EngineerBuilder',
-- ================ --
--    ACU Former    --
-- ================ --
    Builder {
        BuilderName = 'SC CDR Attack Panic',                                    
        PlatoonTemplate = 'CDR Attack Swarm',                                       
        Priority = 700,                                                    
        InstanceCount = 10,                                                 
        BuilderData = {
            SearchRadius = BasePanicZone,
            GetTargetsFromBase = true,                                          
            RequireTransport = false,                                          
            AttackEnemyStrength = 2000,                                         
            IgnorePathing = true,         
            NodeWeight = 10000,                                             
            TargetSearchCategory = categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                            
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
                
            },
            WeaponTargetCategories = {                                      
                categories.COMMAND,
                categories.LAND + categories.INDIRECTFIRE,
                categories.LAND + categories.DIRECTFIRE,
                categories.LAND + categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*3  } },
           
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
       
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
        },
        BuilderType = 'Any',                                                  
    },

    Builder {
        BuilderName = 'SC CDR Attack Military - Usage',                                 
        PlatoonTemplate = 'CDR Attack Swarm',                                      
        Priority = 750,                                                    
        InstanceCount = 10,                                                      
        BuilderData = {
            SearchRadius = BaseMilitaryZone,
            GetTargetsFromBase = true,                                         
            RequireTransport = false,                                           
            AttackEnemyStrength = 2000,                                         
            IgnorePathing = true,                                              
            NodeWeight = 10000,   
            TargetSearchCategory = categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                                
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          
                categories.COMMAND,
                categories.LAND + categories.INDIRECTFIRE,
                categories.LAND + categories.DIRECTFIRE,
                categories.LAND + categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                  
   
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*4 } },

            { UCBC, 'LessThanGameTimeSeconds', { 60*25 } },
         
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
        },
        BuilderType = 'Any',                                              
    },

    -- =============== --
    --    COMMANDER    --
    -- =============== --

    Builder {
        BuilderName = 'SC Assist Hydro',
        PlatoonTemplate = 'CommanderAssistSwarm',
        Priority = 655,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocationSwarm', { 'LocationType', 0, categories.STRUCTURE * categories.HYDROCARBON }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistClosestUnit = true,   
                AssistUntilFinished = true,
                AssistRange = 65,
                BeingBuiltCategories = {categories.STRUCTURE * categories.HYDROCARBON},
                Time = 75,
            },
        }
    }, 

    Builder {
        BuilderName = 'SC Assist Standard',
        PlatoonTemplate = 'CommanderAssistSwarm',
        Priority = 550,
        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                AssistRange = 100,
                BeingBuiltCategories = {categories.TECH1 + categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL},               -- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'SC Assist Energy',
        PlatoonTemplate = 'CommanderAssistSwarm',
        Priority = 650,
        BuilderConditions = {
            { EBC, 'LessThanEnergyTrendSwarm', { 0.0 } }, 

            { EBC, 'GreaterThanMassStorageCurrentSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 0.0 }},

            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocationSwarm', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistClosestUnit = true,   
                AssistUntilFinished = true,
                AssistRange = 100,
                BeingBuiltCategories = {categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH1 + categories.TECH2 + categories.TECH3)},-- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    --==========================--
    -- Commander Energy Builders--
    --==========================--

    Builder {
        BuilderName = 'Swarm Commander Power low trend',
        PlatoonTemplate = 'CommanderBuilderSwarm',
        Priority = 645,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION - categories.TECH1 - categories.COMMAND } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) }},

            { EBC, 'LessThanEnergyTrendOverTimeSwarm', { 0.0 } },             
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.RADAR * categories.STRUCTURE,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                    categories.MASSEXTRACTION * categories.TECH1,
                    categories.ENERGYSTORAGE,   
                },
                BuildClose = true,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Power MassRatio 10',
        PlatoonTemplate = 'CommanderBuilderSwarm',
        Priority = 640,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION - categories.TECH1 - categories.COMMAND } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) }},

            { EBC, 'GreaterThanMassStorageCurrentSwarm', { 200 } }, 

            { EBC, 'EnergyToMassRatioIncomeSwarm', { 10.0, '<=' } },  -- True if we have less than 10 times more Energy then Mass income ( 100 <= 10 = true )
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.RADAR * categories.STRUCTURE,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                    categories.MASSEXTRACTION * categories.TECH1,
                    categories.ENERGYSTORAGE,   
                },
                BuildClose = true,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    }, 

    Builder {
        BuilderName = 'Swarm Commander Land Factory Mass > MassStorage',

        PlatoonTemplate = 'CommanderBuilderSwarm',

        Priority = 650,

        PriorityFunction = HaveLessThanFiveT2LandFactoryACU,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } }, 
            
            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyBias = 'ForwardClose',
                AdjacencyPriority = {
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Land Factory - Land Ratio',

        PlatoonTemplate = 'CommanderBuilderSwarm',

        Priority = 650,

        PriorityFunction = HaveLessThanFiveT2LandFactoryACU,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},

            { UCBC, 'LandStrengthRatioLessThan', { 1.5 } },

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                AdjacencyBias = 'ForwardClose',
                AdjacencyPriority = {
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',  
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Air Factory Mass > MassStorage',

        PlatoonTemplate = 'CommanderBuilderSwarm',

        Priority = 645,

        PriorityFunction = HaveLessThanThreeT2AirFactoryACU,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                AdjacencyBias = 'BackClose',
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.HYDROCARBON,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',  
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Air Factory - Air Ratio',
        
        PlatoonTemplate = 'CommanderBuilderSwarm',

        Priority = 645,

        PriorityFunction = HaveLessThanThreeT2AirFactoryACU,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'AirStrengthRatioLessThan', { 1 } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 8, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                AdjacencyBias = 'BackClose',
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.HYDROCARBON,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',  
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Air Factory - No Air Factory',

        PlatoonTemplate = 'CommanderBuilderSwarm',

        Priority = 655,

        DelayEqualBuildPlattons = {'Factories', 3},
        
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = true,
            Construction = {
                AdjacencyBias = 'BackClose',
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.HYDROCARBON,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',  
                },
            }
        }
    },
}

-- ==================
-- ==================
-- ==================

BuilderGroup { BuilderGroupName = 'Swarm Factory Builder',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Commander Factory Builder Land - Recover',
        PlatoonTemplate = 'CommanderBuilderSwarm',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyPriority = {
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
            	DesiresAssist = true,
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },

    -- Add a Watermap Ratio Condition to replace CanPathTo
    Builder {
        BuilderName = 'Swarm Commander Factory Builder Land - Watermap',
        PlatoonTemplate = 'CommanderBuilderSwarm',
        Priority = 600,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyPriority = {
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
            	DesiresAssist = true,
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Factory Builder Air - First - Watermap',
        PlatoonTemplate = 'CommanderBuilderSwarm',
        Priority = 650,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
            
            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }}, 

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.HYDROCARBON,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
}


-- ===================================================-======================================================== --
-- ==                                           ACU Assistees                                                == --
-- ===================================================-======================================================== --

BuilderGroup {
    BuilderGroupName = 'ACU Support Platoon Swarm',                               
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Shield to ACU Platoon Swarm',
        PlatoonTemplate = 'AddShieldToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoonSwarm',
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) * (categories.TECH2 + categories.TECH3) } },

            { UCBC, 'UnitsLessInPlatoonSwarm', { 'ACUChampionPlatoonSwarm', 2, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) * (categories.TECH2 + categories.TECH3) } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Tank to ACU Platoon Swarm',
        PlatoonTemplate = 'AddTankToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoonSwarm',
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.MOBILE * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL } },

            { UCBC, 'UnitsLessInPlatoonSwarm', { 'ACUChampionPlatoonSwarm', 2, categories.MOBILE * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'AntiAir to ACU Platoon Swarm',
        PlatoonTemplate = 'AddAAToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoonSwarm',
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.MOBILE * categories.LAND * categories.ANTIAIR } },

            { UCBC, 'UnitsLessInPlatoonSwarm', { 'ACUChampionPlatoonSwarm', 3, categories.MOBILE * categories.LAND * categories.ANTIAIR } },
        },
        BuilderType = 'Any',
    },
}