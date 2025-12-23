-- Transform chapters: convert inter-document links to use pandoc's auto-generated IDs
-- Assumes chapter_id_map global variable is set in the combined filter (build/transform-chapters.lua)

function Link(el)
  local target = el.target
  
  -- Step 1: Only process inter-document links (must contain .md)
  if not target:match("%.md([#%$]?)") then
    return el  -- Not a .md link, abort
  end
  
  -- Step 2: Reject absolute paths, parent paths, and protocol URLs
  if target:match("^%/") or target:match("^%.%.") or target:match("^[%l]+:%/%/") then
    return el  -- Absolute path, parent path, or protocol URL, abort
  end
  
  -- Step 3: Handle anchor links (./file.md#section)
  local anchor_pos = target:find("#")
  if anchor_pos then
    local md_anchor = target:match("%.md#(.+)$")
    if md_anchor then
      el.target = "#" .. md_anchor
      return el
    end
    -- Malformed: ends with # or # without content, abort
    return el
  end
  
  -- Step 4: Sanity check - must end with .md
  if not target:match("%.md$") then
    return el  -- Malformed URL, abort
  end
  
  -- Step 5: Extract basename (filename) from path
  -- Try matching with a slash first, then without (to handle ./prefix/file.md and file.md)
  local prefix, md_link = target:match("^(.*%/)([^#]+%.md)$")
  if not md_link then
    -- No slash before filename, match directly
    md_link = target:match("^([^#]+%.md)$")
  end
  if md_link then
    if chapter_id_map and chapter_id_map[md_link] then
      el.target = "#" .. chapter_id_map[md_link]
    end
  end
  
  return el
end
