-- Remove navigation header/footer blocks and NAV_TITLE comments
-- (used only for nav generation, not needed in transformed output)
-- State machine: normal -> skipping_header -> normal -> skipping_footer -> normal

local skipping_header = false
local skipping_footer = false

function Block(el)
  -- Check if this is an HTML comment (RawBlock with html format)
  if el.t == "RawBlock" and el.format == "html" then
    local text = el.text
    
    -- Remove NAV_TITLE comments (standalone, no state needed)
    if text:match("NAV_TITLE") then
      return {}  -- Remove the comment
    end
    
    -- Check for NAV_HEADER_START marker
    if text:match("NAV_HEADER_START") then
      skipping_header = true
      return {}  -- Remove the start marker
    end
    
    -- Check for NAV_HEADER_END marker
    if text:match("NAV_HEADER_END") then
      skipping_header = false
      return {}  -- Remove the end marker
    end
    
    -- Check for NAV_FOOTER_START marker
    if text:match("NAV_FOOTER_START") then
      skipping_footer = true
      return {}  -- Remove the start marker
    end
    
    -- Check for NAV_FOOTER_END marker
    if text:match("NAV_FOOTER_END") then
      skipping_footer = false
      return {}  -- Remove the end marker
    end
  end
  
  -- If we're in skipping state (header or footer), exclude this block
  if skipping_header or skipping_footer then
    return {}
  end
  
  -- Otherwise, include the block
  return el
end

