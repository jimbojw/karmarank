-- Extract local image references from markdown
-- Outputs markdown with only images (excluding protocol URLs like http://, https://)
-- Format: ![](path-to-image.png)

function Image(el)
  local src = el.src
  -- Skip images with protocol URLs (http://, https://, etc.)
  if src:match("^%w+://") then
    return {}  -- Remove protocol URLs
  end
  -- Keep all other images (including local ones)
  return el
end

function Para(el)
  -- Keep paragraphs that contain images, remove others
  local has_image = false
  for _, inline in ipairs(el.content) do
    if inline.t == "Image" then
      has_image = true
      break
    end
  end
  if has_image then
    -- Filter out non-image inline elements
    local filtered_content = {}
    for _, inline in ipairs(el.content) do
      if inline.t == "Image" then
        table.insert(filtered_content, inline)
      end
    end
    return pandoc.Para(filtered_content)
  end
  return {}  -- Remove paragraphs without images
end

function Block(el)
  -- Remove all other block types
  return {}
end

function Inline(el)
  -- Keep only Image elements, remove everything else
  if el.t == "Image" then
    return el
  end
  return {}
end

function Doc(el)
  -- Return document as-is (only images will remain after filtering)
  return el
end
