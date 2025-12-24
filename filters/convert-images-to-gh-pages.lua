-- Convert local image paths to GitHub Pages URLs
-- Only converts images/... or ./images/... paths
-- Leaves protocol URLs and other paths unchanged

local GH_PAGES_BASE = "https://jimbojw.github.io/karmarank"

function Image(el)
  local src = el.src
  
  -- Skip protocol URLs (http://, https://, etc.)
  if src:match("^%w+://") then
    return el
  end
  
  -- Convert images/... or ./images/... to GitHub Pages URLs
  if src:match("^%.%/images/") or src:match("^images/") then
    -- Remove leading ./ if present
    local clean_path = src:gsub("^%.?/", "")
    el.src = GH_PAGES_BASE .. "/" .. clean_path
  end
  
  return el
end

