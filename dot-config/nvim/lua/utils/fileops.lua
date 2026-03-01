-- .config/nvim/lua/core/utils/fileops.lua

local M = {}

---Touch a file, creating if it does not exist
---@param filepath string
---@return boolean True on success
function M.touch_file(filepath)
  local file = io.open(filepath, "a")
  if file then
    file:close()
    return true
  end
  return false
end

---@class DirPickerOpts
---@field title? string Title of the picker
---@field hidden? boolean Show hidden files (default: false)
---@field pattern? string Glob pattern for matching files (default: "*")
---@field reverse? boolean Reverse sort order - oldest first (default: false, most recent first)
---@field dirs? boolean Include directories (default: false)

--- A Snacks file picker, where files are ordered by modification time
--- @param dir string Directory path to search
--- @param opts? DirPickerOpts
function M.pick_files_in_directory(dir, opts)
  opts = opts or {}
  local expanded_dir = vim.fn.expand(dir)
  local pattern = opts.pattern or "*"
  local show_hidden = opts.hidden or false
  local reverse = opts.reverse or false
  local include_dirs = opts.dirs or false

  local paths = vim.fn.globpath(expanded_dir, pattern, false, true)
  if show_hidden then
    vim.list_extend(paths, vim.fn.globpath(expanded_dir, "." .. pattern, false, true))
  end

  if #paths == 0 then
    vim.notify("No files found in " .. dir, vim.log.levels.WARN)
    return
  end

  local items = {}
  for _, path in ipairs(paths) do
    local stat = vim.uv.fs_stat(path)
    if stat then
      local is_dir = stat.type == "directory"
      if include_dirs or not is_dir then
        items[#items + 1] = {
          file = path,
          text = vim.fn.fnamemodify(path, ":t"),
          is_dir = is_dir,
          mtime = stat.mtime.sec,
        }
      end
    end
  end
  table.sort(items, function(a, b) return reverse and (a.mtime < b.mtime) or (a.mtime > b.mtime) end)

  Snacks.picker({
    title = opts.title or ("Files in " .. vim.fn.fnamemodify(expanded_dir, ":~")),
    items = items,
    format = function(item)
      if item.is_dir then
        return { { item.text .. "/", "Directory" } }
      else
        return { { item.text, "Normal" } }
      end
    end,
    confirm = function(picker, item)
      picker:close()
      if item then vim.cmd.edit(item.file) end
    end,
  })
end

return M
