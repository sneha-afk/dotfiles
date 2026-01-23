-- .config/nvim/lua/core/utils/ui.lua

local M = {}

M.ascii_icons = {
  Array = "[] ",
  BlockMappingPair = "{} ",
  Boolean = "bool ",
  BreakStatement = "break ",
  Call = "fn() ",
  CaseStatement = "case ",
  Class = "class ",
  Color = "# ",
  Constant = "const ",
  Constructor = "ctor ",
  ContinueStatement = "cont ",
  Copilot = "AI ",
  Declaration = "decl ",
  Delete = "del ",
  DoStatement = "do ",
  Element = "elem ",
  Enum = "enum ",
  EnumMember = "enumval ",
  Event = "⍺ ",
  Field = "■ ",
  File = "⛶ ",
  Folder = "🖿",
  ForStatement = "for ",
  Function = "ƒ ",
  GotoStatement = "goto ",
  Identifier = "id ",
  IfStatement = "if ",
  Interface = "iface ",
  Keyword = "kw ",
  List = "☰ ",
  Log = "log ",
  Lsp = "LSP ",
  Macro = "macro ",
  MarkdownH1 = "# ",
  MarkdownH2 = "## ",
  MarkdownH3 = "### ",
  MarkdownH4 = "#### ",
  MarkdownH5 = "##### ",
  MarkdownH6 = "###### ",
  Method = "ƒ ",
  Module = "mod ",
  Namespace = "ns ",
  Null = "null ",
  Number = "123 ",
  Object = "▢ ",
  Operator = "op ",
  Package = "pkg ",
  Pair = "pair ",
  Property = "prop ",
  Reference = "ref ",
  Regex = "re ",
  Repeat = "loop ",
  Return = "ret ",
  RuleSet = "rules ",
  Scope = "{} ",
  Section = "§ ",
  Snippet = "✁ ",
  Specifier = "spec ",
  Statement = "stmt ",
  String = '"" ',
  Struct = "struct ",
  SwitchStatement = "switch ",
  Table = "tbl ",
  Terminal = "term ",
  Text = "txt ",
  Type = "type ",
  TypeParameter = "T ",
  Unit = "unit ",
  Value = "val ",
  Variable = "var ",
  WhileStatement = "while ",
}

M.color_cycle = {
  "Statement",
  "Character",
  "Special",
  "Number",
  "Type",
  "Boolean",
}

M.neovim_logo = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]]

-- {} assuming icon set installed elsewhere, i.e an empty merge
function M.get_icon_set()
  return vim.g.use_icons and {} or M.ascii_icons
end

return M
