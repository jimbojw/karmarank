-- filters/man-page-math.lua
-- Convert LaTeX math to readable ASCII for man pages
-- Note: Both inline Math ($...$) and DisplayMath ($$...$$) are Inline elements
-- DisplayMath appears as a Math element with mathtype="DisplayMath" inside Para blocks

-- Helper function to convert LaTeX math to ASCII
local function convert_math_text(math_text)
  -- Convert common LaTeX symbols to ASCII
  math_text = math_text:gsub("\\sum_{([^}]+)}", "Σ_%1")
  math_text = math_text:gsub("\\sum", "Σ")
  math_text = math_text:gsub("\\cdot", "·")
  -- Keep underscores for subscripts (e.g., S_i stays as S_i)
  -- Just remove backslashes
  math_text = math_text:gsub("\\", "")  -- Remove remaining backslashes
  -- Clean up whitespace
  math_text = math_text:gsub("^%s+", ""):gsub("%s+$", "")  -- Trim
  math_text = math_text:gsub("%s+", " ")  -- Normalize spaces
  return math_text
end

function Inline(el)
  if el.t == "Math" then
    -- Convert LaTeX math to ASCII
    local math_text = convert_math_text(el.text)
    return pandoc.Str(math_text)
  end
  -- For other inline elements, return unchanged
  return el
end
