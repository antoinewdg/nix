local opt = vim.opt

function setup()
  setup_looks()
  setup_keymaps()
  setup_general()
end

function setup_looks()
  opt.number = true -- Show line numbers
  opt.relativenumber = false -- Relative line numbers
  opt.termguicolors = true -- True color support


  require('lualine').setup {
    options = {
      section_separators = '',
      component_separators = '',
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch'},
      lualine_c = {'filename'},
      lualine_x = {'filetype'},
      -- lualine_y = {function() return vim.g["metals_status"] end},
      lualine_z = {'location'}
    },
  }

  vim.cmd("let g:gruvbox_material_palette = 'mix'")
  vim.cmd('colorscheme gruvbox-material')
end

function setup_general()

  opt.completeopt = "menuone,noselect,preview"  -- Completion options (for deoplete)
  opt.expandtab = true                  -- Use spaces instead of tabs
  opt.hidden = true                     -- Enable background buffers
  opt.ignorecase = true                 -- Ignore case
  opt.joinspaces = false                -- No double spaces with join
  opt.list = true                       -- Show some invisible characters
  opt.scrolloff = 4                     -- Lines of context
  opt.shiftround = true                 -- Round indent
  opt.shiftwidth = 2                    -- Size of an indent
  opt.sidescrolloff = 8                 -- Columns of context
  opt.smartcase = true                  -- Do not ignore case with capitals
  opt.smartindent = true                -- Insert indents automatically
  opt.splitbelow = true                 -- Put new windows below current
  opt.splitright = true                 -- Put new windows right of current
  opt.tabstop = 2                       -- Number of spaces tabs count for
  opt.wildmode = {'list', 'longest'}    -- Command-line completion mode
  opt.wrap = true                       -- Enable soft wrap
  opt.linebreak = true                  -- Don't soft wrap in the middle of words
  opt.inccommand = 'nosplit'            -- Live substitution for search
  opt.autowriteall = true               -- Save on buffer switch

  -- Apparently required for metals
  vim.opt_global.shortmess:remove("F"):append("c")

  autocmds = {
    -- format = {"BufWritePost * lua format_current_file()"},
    focus = {'FocusLost * silent! wa'},
    yank = {'TextYankPost * lua vim.highlight.on_yank {on_visual = false}'},  -- disabled in visual mode
    lsp = {'FileType scala,sbt lua require("metals").initialize_or_attach({})'},
  }
  create_augroups(autocmds)

  require('nvim-treesitter.configs').setup {
    highlight = {enable = true}
  }

  vim.g['goyo_width'] = 90


  local lsp = require('lspconfig')
  local lsp_util = require 'lspconfig.util'
  local lsp_format = require 'lsp-format';

  vim.lsp.set_log_level('debug')
  lsp_format.setup {}

  lsp.pyright.setup {}
  lsp.rust_analyzer.setup({})
  lsp.terraformls.setup({})

  lsp.efm.setup {
    on_attach = lsp_format.on_attach,
    root_dir = lsp_util.root_pattern("pyrightconfig.json"),
    init_options = {documentFormatting = true},
    settings = {
        rootMarkers = {".git/"},
        languages = {
            python = {
                {formatCommand = "black --quiet -", formatStdin = true},
            }
        }
    }
}

  require("nvim_comment").setup {}


  local actions = require('telescope.actions')
  require('telescope').setup {
    defaults = {
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
        }
      }
    }
  }

  require("compe").setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = 'enable',
    throttle_time = 80,

    documentation = true,

    source = {
      path = true,
      buffer = true,
      calc = true,
      nvim_lsp = true,
      nvim_lua = true,
      vsnip = true,
      ultisnips = true,
      luasnip = true,
    },
  }

end

function setup_keymaps()
  local vimp = require('vimp')
  local telescope = require("telescope.builtin")

  vimp.add_chord_cancellations('n', '<space>')
  -- Completion
  vimp.bind('i', '<C-j>', '<C-n>')
  vimp.bind('i', '<C-k>', '<C-p>')
  vimp.bind('i', {'expr'}, '<CR>', 'compe#confirm("<CR>")')

  -- Move correctly across wrapped lines (I can't believe I could not find a setting
  -- for this).
  vimp.rbind('nx', 'j', 'gj')
  vimp.rbind('nx', 'k', 'gk')
  -- Dumb stuff
  vimp.bind('n', ':W', ':w')
  vimp.bind('n', 'y', '"+y') -- Always yank to the system clipboard
  -- Editor
  vimp.bind('n', '<space>ee', reload_config)
  vimp.bind('n', '<space>ec', ':e '.. vim.fn.stdpath('config') .. '/init.lua<CR>')
  -- Windows
  vimp.bind('n', '<space>wh', '<C-w>h')
  vimp.bind('n', '<space>wj', '<C-w>j')
  vimp.bind('n', '<space>wk', '<C-w>k')
  vimp.bind('n', '<space>wl', '<C-w>l')
  vimp.bind('n', '<space>wd', '<C-w>c')
  vimp.bind('n', '<space>wn', ':vsplit<CR>')
  -- Code
  vimp.bind('n', '<space>ca', vim.lsp.buf.code_action)
  vimp.bind('n', '<space>cd', vim.lsp.buf.definition)
  vimp.bind('n', '<space>bf', format_current_file)
  vimp.bind('n', '<space>h', vim.lsp.buf.hover)
  vimp.bind('n', '<C-h>', vim.lsp.diagnostic.show_line_diagnostics)
  vimp.bind('n', '<space>cr', vim.lsp.buf.rename)
  -- Telescope
  vimp.bind('n', '<space>pf', function ()
    telescope.find_files({ find_command = {"rg", "--ignore", "--hidden", "--files", "--glob=!.git/**/*"} })
  end)
  vimp.bind('n', '<space>bD', remove_current_file)

  vimp.bind('n', '<space>ph', telescope.help_tags)
  vimp.bind('n', '<space>ps', telescope.live_grep)
  vimp.bind('n', '<space>bb', telescope.buffers)
  vimp.bind('n', '<space>fr', telescope.oldfiles)
  vimp.bind('n', '<space>cf', function() telescope.lsp_references { opts = {include_declaration = false} } end )
  -- Git
  vimp.bind('n', '<space>go', 'V:OpenGithubFile<CR>')
  vimp.bind('v', '<space>go', ':OpenGithubFile<CR>')
  -- Other
  vimp.bind('n', '<space>bp', ':ls<cr>:b<space>')
  vimp.bind('n', '<space>j', vim.lsp.diagnostic.goto_prev)
  vimp.bind('n', '<space>k', vim.lsp.diagnostic.goto_next)
  vimp.bind('n', '<space>s', vim.lsp.buf.document_symbol)

  -- Disable ex mode
  vimp.bind('n', 'Q', '<Nop>')

end

function _G.format_current_file()
  vim.cmd ':w'
  if vim.bo.filetype == "scala" then
    vim.lsp.buf.formatting()
    vim.cmd ':w'
  else
     vim.cmd 'FormatWrite'
  end
end


-- Helpers -------------------------------

function create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    vim.api.nvim_command('augroup '..group_name)
    vim.api.nvim_command('autocmd!')
    for _, def in ipairs(definition) do
      local command = string.format('autocmd %s', def)
      vim.api.nvim_command(command)
    end
    vim.api.nvim_command('augroup END')
  end
end

function unload_lua_namespace(prefix)
  local prefix_with_dot = prefix .. '.'
  for key, value in pairs(package.loaded) do
    if key == prefix or key:sub(1, #prefix_with_dot) == prefix_with_dot then
      package.loaded[key] = nil
    end
  end
end

function reload_config()
  -- Remove all previously added vimpeccable maps
  vimp.unmap_all()
  -- Unload the lua namespace so that the next time require('config.X') is called
  -- it will reload the file
  unload_lua_namespace('config')
  -- Make sure all open buffers are saved
  vim.cmd('silent wa')
  -- Execute our vimrc lua file again to add back our maps
  dofile(vim.fn.stdpath('config') .. '/init.lua')
  print("Reloaded vimrc!")
end

function remove_current_file()
  local path = vim.fn.expand("%")
  if vim.fn.input("Remove " .. path .. "? (y/n) ") == "y" then
    vim.fn.delete(path)
    vim.cmd(":bdelete!")
  end
end

setup()
