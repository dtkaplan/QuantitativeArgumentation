-- Native Quarto Custom Shortcode Implementation
local function exercise(args, kwargs, meta)
  -- Validate that a file argument was provided
  if #args < 1 then
    error("The {{< exercise >}} shortcode requires a file path argument.")
  end
  
  -- Extract and stringify the input file path from the arguments array
  local filepath = pandoc.utils.stringify(args[1])
  
  -- Attempt to locate and open the transcluded exercise file
  local file = io.open(filepath, "r")
  if not file then
    return pandoc.Para({
      pandoc.Strong(pandoc.Str("[Error: Could not find file " .. filepath .. "]"))
    })
  end
  
  local content = file:read("*all")
  file:close()
  
  -- Define your boilerplate formatting strings
  local before_text = "### Exercise\n\n*before placeholder*\n\n"
  local after_text = "\n\n*after placeholder*\n\n---"
  
  -- Splice text layers together
  local full_markdown = before_text .. content .. after_text
  
  -- Parse the unified string back into formal document blocks
  return pandoc.read(full_markdown, "markdown").blocks
end

-- Return the function mapped to the exact shortcode execution handle
return {
  ['exercise'] = exercise
}

