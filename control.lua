-- WePlay: Taxi Train - electric charging
--
-- The taxi's burner works as its battery: script keeps a hidden
-- "wp-taxi-charge" item burning in it (fuel value = battery size) and adds
-- energy to remaining_burning_fuel. While a taxi stands still, an invisible
-- charger (electric-energy-interface) sits under it and draws from whatever
-- power pole network covers that spot.

local TAXI = "wp-taxi-locomotive"
local CHARGER = "wp-taxi-charger"
local CHARGE_ITEM = "wp-taxi-charge"
local INTERVAL = 10           -- ticks between charging updates

local battery_size            -- joules, read from the charge item at runtime

local function capacity()
  if not battery_size then
    local item = prototypes.item[CHARGE_ITEM]
    battery_size = item and item.fuel_value or 100e6
  end
  return battery_size
end

local function setup_storage()
  storage.taxis = storage.taxis or {}   -- unit_number -> {loco, charger}
end

---------------------------------------------------------------- battery

-- Make sure the burner is "burning" our charge item, and clear out any
-- leftover real fuel from before the taxi went electric.
local function prepare_burner(loco)
  local burner = loco.burner
  if not burner then return nil end

  local inv = burner.inventory
  if inv and not inv.is_empty() then
    for i = 1, #inv do
      local stack = inv[i]
      if stack.valid_for_read then
        loco.surface.spill_item_stack{position = loco.position, stack = stack,
          force = loco.force, allow_belts = false}
        stack.clear()
      end
    end
  end

  local burning = burner.currently_burning
  local burning_name = burning and burning.name
  if type(burning_name) ~= "string" then burning_name = burning_name and burning_name.name end
  if burning_name ~= CHARGE_ITEM then
    burner.currently_burning = CHARGE_ITEM
    burner.remaining_burning_fuel = 0
  end
  return burner
end

local function remove_charger(data)
  if data.charger and data.charger.valid then data.charger.destroy() end
  data.charger = nil
end

local function track(loco)
  if not (loco and loco.valid and loco.name == TAXI) then return end
  setup_storage()
  if not storage.taxis[loco.unit_number] then
    storage.taxis[loco.unit_number] = {loco = loco}
  end
  prepare_burner(loco)
end

local function untrack(unit_number)
  local data = storage.taxis and storage.taxis[unit_number]
  if not data then return end
  remove_charger(data)
  storage.taxis[unit_number] = nil
end

local function find_all_taxis()
  setup_storage()
  for _, surface in pairs(game.surfaces) do
    for _, loco in pairs(surface.find_entities_filtered{name = TAXI}) do
      track(loco)
    end
  end
end

---------------------------------------------------------------- charging

local function update(unit_number, data)
  local loco = data.loco
  if not (loco and loco.valid) then
    untrack(unit_number)
    return
  end

  local burner = prepare_burner(loco)
  local train = loco.train
  local stopped = train and train.speed == 0
  local cap = capacity()
  local full = burner and burner.remaining_burning_fuel >= cap - 1

  if not (burner and stopped and not full) then
    remove_charger(data)
    return
  end

  local charger = data.charger
  if charger and charger.valid then
    local p, q = charger.position, loco.position
    if charger.surface ~= loco.surface or math.abs(p.x - q.x) > 0.5 or math.abs(p.y - q.y) > 0.5 then
      remove_charger(data)
      charger = nil
    end
  else
    charger = nil
  end

  if not charger then
    charger = loco.surface.create_entity{
      name = CHARGER, position = loco.position, force = loco.force, create_build_effect_smoke = false,
    }
    if not charger then return end
    charger.destructible = false
    data.charger = charger
    return   -- it starts drawing power next tick
  end

  local stored = charger.energy
  if stored <= 0 then return end
  local room = cap - burner.remaining_burning_fuel
  local moved = math.min(stored, room)
  burner.remaining_burning_fuel = burner.remaining_burning_fuel + moved
  charger.energy = stored - moved
end

local function on_tick_interval()
  if not storage.taxis then return end
  for unit_number, data in pairs(storage.taxis) do
    update(unit_number, data)
  end
end

---------------------------------------------------------------- events

local function on_built(event)
  track(event.entity or event.destination)
end

local function on_removed(event)
  local entity = event.entity
  if entity and entity.valid and entity.name == TAXI then
    untrack(entity.unit_number)
  end
end

script.on_init(function()
  setup_storage()
  find_all_taxis()
end)

script.on_configuration_changed(function()
  battery_size = nil
  setup_storage()
  find_all_taxis()
end)

script.on_nth_tick(INTERVAL, on_tick_interval)

local taxi_filter = {{filter = "name", name = TAXI}}
script.on_event(defines.events.on_built_entity, on_built, taxi_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, taxi_filter)
script.on_event(defines.events.on_space_platform_built_entity, on_built, taxi_filter)
script.on_event(defines.events.script_raised_built, on_built, taxi_filter)
script.on_event(defines.events.script_raised_revive, on_built, taxi_filter)
script.on_event(defines.events.on_entity_cloned, on_built, taxi_filter)

script.on_event(defines.events.on_player_mined_entity, on_removed, taxi_filter)
script.on_event(defines.events.on_robot_mined_entity, on_removed, taxi_filter)
script.on_event(defines.events.on_space_platform_mined_entity, on_removed, taxi_filter)
script.on_event(defines.events.on_entity_died, on_removed, taxi_filter)
script.on_event(defines.events.script_raised_destroy, on_removed, taxi_filter)
