-- Remove navigation footer blocks (NAV_FOOTER_START to NAV_FOOTER_END)
-- and NAV_TITLE comments (used only for nav generation, not needed in output)
-- State machine: normal -> skipping -> normal

local skipping = false

function Block(el)
  -- Check if this is an HTML comment (RawBlock with html format)
  if el.t == "RawBlock" and el.format == "html" then
    local text = el.text
    
    -- Remove NAV_TITLE comments (standalone, no state needed)
    if text:match("NAV_TITLE") then
      return {}  -- Remove the comment
    end
    
    -- Check for NAV_FOOTER_START marker
    if text:match("NAV_FOOTER_START") then
      skipping = true
      return {}  -- Remove the start marker
    end
    
    -- Check for NAV_FOOTER_END marker
    if text:match("NAV_FOOTER_END") then
      skipping = false
      return {}  -- Remove the end marker
    end
  end
  
  -- If we're in skipping state, exclude this block
  if skipping then
    return {}
  end
  
  -- Otherwise, include the block
  return el
end

