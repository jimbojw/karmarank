-- filters/man-page-images.lua
-- Convert images to text descriptions for man pages
-- Assumes image_ascii_map global variable is set in the combined filter (build/man-page-images.lua)

-- Helper function to extract base name from image src
-- Lua patterns don't support alternation (|), so we try both variants
local function get_image_base_name(src)
  -- Try with images/ prefix and light variant
  local base_name = src:match("images/([^%.]+)%.light%.png")
  if not base_name then
    -- Try with images/ prefix and dark variant
    base_name = src:match("images/([^%.]+)%.dark%.png")
  end
  if not base_name then
    -- Try without images/ prefix and light variant
    base_name = src:match("([^%.]+)%.light%.png")
  end
  if not base_name then
    -- Try without images/ prefix and dark variant
    base_name = src:match("([^%.]+)%.dark%.png")
  end
  return base_name
end

-- Process paragraphs that contain images
function Para(el)
  -- Check if this paragraph contains an image
  local image_base_name = nil
  
  for _, inline in ipairs(el.content) do
    if inline.t == "Image" then
      local base_name = get_image_base_name(inline.src)
      if base_name and image_ascii_map and image_ascii_map[base_name] then
        image_base_name = base_name
        break
      end
    end
  end
  
  -- If we found an image with ASCII art, replace the entire paragraph with a CodeBlock
  if image_base_name then
    return pandoc.CodeBlock(image_ascii_map[image_base_name])
  end
  
  -- Otherwise, process images in the paragraph normally (fallback to Image function)
  -- Check if there are any images that need fallback handling
  local needs_fallback = false
  for _, inline in ipairs(el.content) do
    if inline.t == "Image" then
      needs_fallback = true
      break
    end
  end
  
  if needs_fallback then
    -- Process images with fallback
    local new_content = {}
    for _, inline in ipairs(el.content) do
      if inline.t == "Image" then
        local alt_text = "Image"
        if inline.title and inline.title ~= "" then
          alt_text = inline.title
        elseif inline.caption and #inline.caption > 0 then
          alt_text = pandoc.utils.stringify(inline.caption)
        end
        table.insert(new_content, pandoc.Emph({pandoc.Str("[" .. alt_text .. "]")}))
      else
        table.insert(new_content, inline)
      end
    end
    return pandoc.Para(new_content)
  end
  
  return el
end

-- Don't process Image inline - let Para handle it
-- This ensures we can replace the entire Para with a CodeBlock
function Image(el)
  -- Just pass through - Para will handle replacement
  return el
end
