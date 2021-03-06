#! /usr/bin/env lua

local lfs = require( 'lfs' )

local routine_name = 'helper_get_calcua_generic_current'
local stack_name = 'calcua'

if #arg ~= 1 then
    io.stderr:write( routine_name .. ': ERROR: One command line argument is expected: the version of the calcua stack.\n' )
    os.exit( 1 )
end

local stack_version = arg[1]

local script_called_dir = arg[0]:match( '(.*)/[^/]+' )
lfs.chdir( script_called_dir )
local repo_root = lfs.currentdir():match( '(.*)/scripts/calcua_tools' )
local root_dir = repo_root:match( '(.*)/[^/]+' )

dofile( repo_root .. '/scripts/calcua_tools/lmod_emulation.lua' )
dofile( repo_root .. '/etc/SystemDefinition.lua' )
dofile( repo_root .. '/LMOD/SitePackage_helper.lua' )
dofile( repo_root .. '/LMOD/SitePackage_system_info.lua' )
dofile( repo_root .. '/LMOD/SitePackage_map_toolchain.lua' )
dofile( repo_root .. '/LMOD/SitePackage_arch_hierarchy.lua' )


if CalcUA_SystemTable[stack_version] == nil then
    io.stderr:write( routine_name .. ': ERROR: The stack version ' .. stack_version .. ' is not recognized as a valid stack.\n' ..
                     'Maybe CalcUA_SystemTable in etc/SystemDefinition.lua needs updating?\n' )
    os.exit( 1 )
end

--
-- Actual code
--
print( get_calcua_generic_current( stack_version ) )
