-- Saves that already researched Railway get the taxi recipe right away.
for _, force in pairs(game.forces) do
  local tech = force.technologies["railway"]
  local recipe = force.recipes["wp-taxi-locomotive"]
  if tech and recipe and tech.researched then recipe.enabled = true end
end
