-- Extract only the first H1 header (everything else is dropped)
-- This is used to discover pandoc's auto-generated ID for each chapter

local first_h1_found = false

function Header(el)
  if el.level == 1 and not first_h1_found then
    first_h1_found = true
    -- Return just the header - pandoc will auto-generate the ID
    return el
  end
  -- Drop everything else
  return {}
end

-- Drop all other block elements
function Block(el)
  return {}
end

-- Drop all inline elements that aren't part of the first H1
function Inline(el)
  return {}
end

