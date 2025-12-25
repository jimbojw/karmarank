-- Filter light/dark mode images for build output
-- Removes #gh-dark-mode-only images entirely
-- Strips #gh-light-mode-only hash from light images (so they render normally)

function Image(el)
  local src = el.src
  
  -- Remove dark mode images entirely
  if src:match("#gh%-dark%-mode%-only$") then
    return {}  -- Remove the image
  end
  
  -- Strip #gh-light-mode-only hash from light images
  if src:match("#gh%-light%-mode%-only$") then
    el.src = src:gsub("#gh%-light%-mode%-only$", "")
  end
  
  return el
end

-- Handle link-wrapped images (links containing images)
function Link(el)
  local target = el.target
  
  -- Remove dark mode links entirely
  if target:match("#gh%-dark%-mode%-only$") then
    return {}  -- Remove the link
  end
  
  -- Strip #gh-light-mode-only hash from light mode links
  if target:match("#gh%-light%-mode%-only$") then
    el.target = target:gsub("#gh%-light%-mode%-only$", "")
  end
  
  return el
end

