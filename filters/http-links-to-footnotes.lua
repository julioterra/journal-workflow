-- http-links-to-footnotes.lua
-- Convert HTTP/HTTPS links to endnotes (footnotes at back of book)

function Link(el)
  local target = el.target or ""

  -- Check if this is an HTTP or HTTPS link
  if target:match("^https?://") then
    -- Escape special LaTeX characters in URL for endnote
    local escaped_url = target:gsub("([#%%&_{}~^\\])", "\\%1")

    -- Create endnote using raw LaTeX with \protect\url for proper line breaking
    local endnote_cmd = pandoc.RawInline('latex', '\\endnote{\\protect\\url{' .. escaped_url .. '}}')

    -- Return the link text followed by the endnote
    local result = {}
    for _, item in ipairs(el.content) do
      table.insert(result, item)
    end
    table.insert(result, endnote_cmd)

    return result
  end

  -- Return other links unchanged
  return el
end

return {
  {Link = Link}
}
