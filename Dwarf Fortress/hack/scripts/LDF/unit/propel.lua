--unit/propel.lua v1.0 | DFHack 43.05

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unitSource',
 'unitTarget',
 'velocity',
 'mode',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/propel.lua
  Flings a unit by turning them into a projectile
  arguments:
   -help
     print this help message
   -unitTarget id
     REQUIRED
     id of the unit to use turn into a projectile
   -unitSource id
     id of the unit to use to use for positioning
     required if using -relative
   -velocity [ # # # ]
     velocity in x,y,z coordinates
     DEFAULT [ 0 0 0 ]
   -mode Type
     Valid Types:
      Fixed
      Random
      Relative
 ]])
 return
end

if args.mode == 'Fixed' or args.mode == 'fixed' then
 propelType = 'fixed'
elseif args.mode == 'Random' or args.mode == 'random' then
 propelType = 'random'
elseif args.mode == 'Relative' or args.mode == 'relative' then
 propelType = 'relative'
else
 propelType = 'fixed'
end

if args.unitTarget and tonumber(args.unitTarget) then
 unit = df.unit.find(tonumber(args.unitTarget))
else
 print('No target specified')
 return
end
if args.unitSource and tonumber(args.unitSource) then
 unitSource = df.unit.find(tonumber(args.unitSource))
else
 unitSource = nil
end

strength = args.velocity or {0,0,0}
local vx = strength[1]
local vy = strength[2]
local vz = strength[3]

if propelType == 'random' then
 local rando = dfhack.random.new()
 rollx = rando:unitrandom()*vx
 rolly = rando:unitrandom()*vy
 rollz = rando:unitrandom()*vz
 resultx = math.floor(rollx)
 resulty = math.floor(rolly)
 resultz = math.floor(rollz)
elseif propelType == 'fixed' then
 resultx = vx
 resulty = vy
 resultz = vz
elseif propelType == 'relative' then
 if unitSource then
 difx = unit.pos.x - unitSource.pos.x
 dify = unit.pos.y - unitSource.pos.y
 difz = unit.pos.z - unitSource.pos.z
 totvel = math.sqrt(vx*vx+vy*vy+vz*vz)
 totdis = math.sqrt(difx*difx+dify*dify+difz*difz)
 dx = difx/totdis
 dy = dify/totdis
 dz = difz/totdis
 if difx == 0 and dify == 0 and difz == 0 then
  dx = (rando:random(3) - 1)/math.sqrt(3)
  dy = (rando:random(3) - 1)/math.sqrt(3)
  dz = (rando:random(3) - 1)/math.sqrt(3)
 end
 else
  print('Relative velocity selected, but no source declared')
  return
 end
 resultx = math.floor(totvel*dx+0.5)
 resulty = math.floor(totvel*dy+0.5)
 resultz = math.floor(totvel*dz+0.5)
else
 print('Not a valid type')
 return
end

dfhack.script_environment('functions/unit').makeProjectile(unit,{resultx,resulty,resultz})
