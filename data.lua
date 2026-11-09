-- WePlay: Taxi Train
-- A half-size locomotive: two fit in one vanilla car's slot.

local gfx = "__WePlayTaxiLocomotive__/graphics/"

-- Sheets are rendered at 64 px per tile, so scale 0.5 = 1:1 in game.
-- 0.41 shrinks the body to about 2.5 tiles long.
local SPRITE_SCALE = 0.41
local SPRITE_SHIFT = {0, 0}   -- nudge here if it doesn't sit on the rails
-- The flat sheet was rendered at 76.8 px per tile (384 px canvas, ortho
-- scale 5); the sloped sheets at 64 px per tile. This evens them out.
local SLOPED_SCALE = SPRITE_SCALE * 76.8 / 64

local loco = table.deepcopy(data.raw["locomotive"]["locomotive"])
loco.name = "wp-taxi-locomotive"
loco.icon = gfx .. "taxi-locomotive-icon.png"
loco.icon_size = 64
loco.icons = nil
loco.minable = {mining_time = 0.5, result = "wp-taxi-locomotive"}

-- Half size: about 2.5 tiles long. Cars sit joint_distance +
-- connection_distance apart (center to center), so two taxis fill one
-- vanilla car's slot. Close bogies make it stick out past its joints like
-- vanilla cars do, so it lines up with the white placement guides.
loco.joint_distance = 1
loco.connection_distance = 2.3
loco.collision_box = {{-0.6, -1.25}, {0.6, 1.25}}
loco.selection_box = {{-1.1, -1.5}, {1.1, 1.5}}
loco.vertical_selection_shift = -0.25

-- Zippy taxi stats
loco.max_speed = 2.4          -- tiles/tick; x 216 = 518 km/h
loco.max_power = "1MW"        -- output (like Real Shuttle Train)
loco.weight = 300
loco.stop_trigger = nil       -- no steam puffs when it stops

-- Electric! Locomotives can only use a burner (or nothing), so the taxi's
-- "battery" is a burner that only takes a hidden charge item worth 100 MJ.
-- control.lua tops it up at 10 MW from the power grid whenever the taxi is
-- stopped near a powered pole. Nothing can be put in the fuel slot by hand.
local BATTERY = "100MJ"
local CHARGE_RATE = "10MW"    -- input

loco.energy_source = {
  type = "burner",
  fuel_categories = {"wp-taxi-charge"},
  effectivity = 1,
  fuel_inventory_size = 1,
}

-- Graphics: flat frames (rotated) and rail ramp frames (sloped).
-- The model has its own skirt, so no bogies.
loco.pictures = {
  rotated = {
    layers = {
      {
        filename = gfx .. "taxi-locomotive.png",
        direction_count = 64,
        line_length = 8,
        width = 384,
        height = 384,
        scale = SPRITE_SCALE,
        shift = SPRITE_SHIFT,
      },
      {
        -- Shadow: 8x8 frames of 448x448, same order and center as the body.
        filename = gfx .. "taxi-locomotive-shadow.png",
        direction_count = 64,
        line_length = 8,
        width = 448,
        height = 448,
        scale = SPRITE_SCALE,
        shift = SPRITE_SHIFT,
        draw_as_shadow = true,
      },
    },
  },
  -- Rail ramps: 4 headings (N, E, S, W) x 40 tilts, like vanilla's locomotive.
  slope_angle_between_frames = 1.25,
  slope_back_equals_front = false,
  sloped = {
    layers = {
      {
        filenames = {gfx .. "taxi-locomotive-sloped-body-1.png"},
        direction_count = 160,
        line_length = 10,
        lines_per_file = 16,
        width = 448,
        height = 448,
        scale = SLOPED_SCALE,
        shift = SPRITE_SHIFT,
      },
      -- Sloped shadow goes here once it's re-rendered at 768x512:
      {
        filenames = {gfx .. "taxi-locomotive-sloped-shadow-1.png"},
        direction_count = 160,
        line_length = 10,
        lines_per_file = 16,
        width = 768,
        height = 512,
        scale = SLOPED_SCALE,
        shift = SPRITE_SHIFT,
        draw_as_shadow = true,
      },
    },
  },
}
loco.wheels = nil

-- Vanilla lights are placed for a 6-tile loco (ends at +/-3). Ours ends at
-- about +/-1.25, so slide the tail lights forward and the headlights back.
local function slide_lights(lights, dy)
  if not lights then return end
  if lights.shift or lights.picture or lights.intensity then lights = {lights} end
  for _, light in pairs(lights) do
    local s = light.shift
    if s then
      if s.y then s.y = s.y + dy else s[2] = (s[2] or 0) + dy end
    end
  end
end
slide_lights(loco.back_light, -1.75)
slide_lights(loco.front_light, 1.75)

-- These vanilla extras are drawn for a 6-tile loco, so drop them for now.
loco.front_light_pictures = nil
loco.stand_by_light = nil
loco.water_reflection = nil
loco.minimap_representation = nil
loco.selected_minimap_representation = nil

data:extend({
  loco,
  {
    type = "fuel-category",
    name = "wp-taxi-charge",
    hidden = true,
  },
  {
    -- Never exists as a real item: script sets it as the burner's
    -- "currently burning" fuel, and its fuel value is the battery size.
    type = "item",
    name = "wp-taxi-charge",
    icon = gfx .. "taxi-locomotive-icon.png",
    icon_size = 64,
    hidden = true,
    flags = {"only-in-cursor"},
    fuel_categories = {"wp-taxi-charge"},
    fuel_value = BATTERY,
    stack_size = 1,
  },
  {
    -- Invisible charger the script drops under a stopped taxi. It draws from
    -- whatever pole network covers that spot, like any other machine would.
    type = "electric-energy-interface",
    name = "wp-taxi-charger",
    icon = gfx .. "taxi-locomotive-icon.png",
    icon_size = 64,
    hidden = true,
    flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable",
      "not-selectable-in-game", "not-flammable", "no-copy-paste", "not-upgradable"},
    collision_mask = {layers = {}},
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{0, 0}, {0, 0}},
    selectable_in_game = false,
    allow_copy_paste = false,
    gui_mode = "none",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      buffer_capacity = "2MJ",   -- a bit over 10 ticks at 10 MW
      input_flow_limit = CHARGE_RATE,
      output_flow_limit = "0W",
      render_no_power_icon = false,
      render_no_network_icon = false,
    },
    energy_production = "0W",
    energy_usage = "0W",
    picture = {filename = "__core__/graphics/empty.png", width = 1, height = 1},
  },
  {
    type = "item-with-entity-data",
    name = "wp-taxi-locomotive",
    icon = gfx .. "taxi-locomotive-icon.png",
    icon_size = 64,
    subgroup = "train-transport",
    order = "a[train-system]-f[wp-taxi-locomotive]",
    place_result = "wp-taxi-locomotive",
    stack_size = 5,
  },
  {
    type = "recipe",
    name = "wp-taxi-locomotive",
    enabled = false,  -- unlocked by the Railway research (below)
    energy_required = 2,
    ingredients = {
      {type = "item", name = "iron-plate", amount = 10},
      {type = "item", name = "iron-gear-wheel", amount = 5},
    },
    results = {{type = "item", name = "wp-taxi-locomotive", amount = 1}},
  },
})

-- Unlock alongside the vanilla locomotive. If another mod removed the
-- Railway research, fall back to unlocked from the start.
local railway = data.raw.technology["railway"]
if railway then
  railway.effects = railway.effects or {}
  table.insert(railway.effects, {type = "unlock-recipe", recipe = "wp-taxi-locomotive"})
else
  data.raw.recipe["wp-taxi-locomotive"].enabled = true
end
