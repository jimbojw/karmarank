-- filters/man-page-images.lua
-- Convert images to text descriptions for man pages

function Image(el)
  -- Try to get alt text from title, caption, or use default
  local alt_text = "Image"
  if el.title and el.title ~= "" then
    alt_text = el.title
  elseif el.caption and #el.caption > 0 then
    alt_text = pandoc.utils.stringify(el.caption)
  end
  -- Return as inline text (works for both Block and Inline contexts)
  return pandoc.Emph({pandoc.Str("[" .. alt_text .. "]")})
end
