-- image-page-filter.lua
-- Ensures one image per page and automatically rotates landscape images

-- Function to URL decode
function url_decode(str)
  str = string.gsub(str, "%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end)
  return str
end

-- Function to get image dimensions using ImageMagick identify
function get_image_dimensions(image_path)
  -- URL decode the path
  local decoded_path = url_decode(image_path)

  -- Prepend assets/ if path doesn't start with /
  if not decoded_path:match("^/") then
    decoded_path = "assets/" .. decoded_path
  end

  local handle = io.popen("identify -format '%w %h' \"" .. decoded_path .. "\" 2>/dev/null")
  if not handle then
    return nil, nil
  end

  local result = handle:read("*a")
  handle:close()

  if result and result ~= "" then
    local width, height = result:match("(%d+)%s+(%d+)")
    return tonumber(width), tonumber(height)
  end

  return nil, nil
end

function Figure(fig)
  -- Check if figure contains an image
  if not fig.content or #fig.content == 0 then
    return fig
  end

  -- Find the first image in the figure
  local img = nil
  local img_elem = nil
  for i, elem in ipairs(fig.content) do
    if elem.t == "Para" or elem.t == "Plain" then
      for j, inline in ipairs(elem.content) do
        if inline.t == "Image" then
          img = inline
          img_elem = elem
          break
        end
      end
    end
    if img then break end
  end

  if not img then
    return fig
  end

  -- Get image path (handle relative paths from markdown)
  local img_src = img.src

  -- Try to get image dimensions
  local width, height = get_image_dimensions(img_src)
  local is_landscape = false

  if width and height then
    is_landscape = width > height
  end

  -- Build LaTeX wrapper
  local blocks = pandoc.Blocks{}

  -- Clear page before image
  blocks:insert(pandoc.RawBlock('latex', '\\clearpage'))

  -- Choose figure environment based on orientation
  if is_landscape then
    blocks:insert(pandoc.RawBlock('latex', '\\begin{sidewaysfigure}[p]'))
    blocks:insert(pandoc.RawBlock('latex', '\\centering'))
    -- For rotated landscape images:
    -- Image width (becomes vertical after rotation) must fit in page height with margins
    -- Image height (becomes horizontal after rotation) must fit in page width with room for caption
    -- Use constraints: 80% of page height for width, 50% of page width for height
    blocks:insert(pandoc.RawBlock('latex', '\\includegraphics[width=0.80\\textheight,height=0.50\\textwidth,keepaspectratio]{' .. url_decode(img.src) .. '}'))
  else
    blocks:insert(pandoc.RawBlock('latex', '\\begin{figure}[p]'))
    blocks:insert(pandoc.RawBlock('latex', '\\centering'))
    -- For portrait images: standard constraints
    blocks:insert(pandoc.RawBlock('latex', '\\includegraphics[width=\\textwidth,height=0.7\\textheight,keepaspectratio]{' .. url_decode(img.src) .. '}'))
  end

  -- Add caption if present (escape LaTeX special characters)
  if fig.caption and fig.caption.long and #fig.caption.long > 0 then
    local caption_text = pandoc.utils.stringify(fig.caption.long)
    -- Escape LaTeX special characters
    caption_text = caption_text:gsub("\\", "\\textbackslash ")
    caption_text = caption_text:gsub("_", "\\_")
    caption_text = caption_text:gsub("#", "\\#")
    caption_text = caption_text:gsub("%%", "\\%%")
    caption_text = caption_text:gsub("&", "\\&")
    caption_text = caption_text:gsub("%$", "\\$")
    caption_text = caption_text:gsub("{", "\\{")
    caption_text = caption_text:gsub("}", "\\}")
    caption_text = caption_text:gsub("~", "\\textasciitilde ")
    caption_text = caption_text:gsub("%^", "\\textasciicircum ")
    blocks:insert(pandoc.RawBlock('latex', '\\caption{' .. caption_text .. '}'))
  end

  -- Close figure environment
  if is_landscape then
    blocks:insert(pandoc.RawBlock('latex', '\\end{sidewaysfigure}'))
  else
    blocks:insert(pandoc.RawBlock('latex', '\\end{figure}'))
  end

  blocks:insert(pandoc.RawBlock('latex', '\\clearpage'))

  return blocks
end

return {
  { Figure = Figure }
}
