return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = require("config.theme").get() },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      background = { dark = "mocha", light = "latte" },
      integrations = {
        blink_cmp = true,
        dap = true,
        dap_ui = true,
        gitsigns = true,
        mason = true,
        native_lsp = { enabled = true },
        neotest = true,
        snacks = true,
        treesitter = true,
        which_key = true,
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = { style = "night", styles = { sidebars = "transparent", floats = "transparent" } },
  },
  {
    "rebelot/kanagawa.nvim",
    opts = { theme = "wave", background = { dark = "wave", light = "lotus" } },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = { variant = "main", styles = { transparency = false } },
  },
  {
    "sainnhe/gruvbox-material",
    init = function()
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_better_performance = 1
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 400,
        ignore_whitespace = true,
        virt_text = true,
        virt_text_pos = "right_align",
      },
      current_line_blame_formatter = require("config.git").blame_formatter,
    },
  },
  {
    "Bekaboo/dropbar.nvim",
    event = "LspAttach",
    opts = {
      bar = {
        enable = function(buf, win)
          return vim.api.nvim_buf_is_valid(buf)
            and vim.api.nvim_win_is_valid(win)
            and vim.bo[buf].buftype == ""
            and vim.fn.win_gettype(win) == ""
            and not vim.wo[win].diff
        end,
      },
    },
    keys = {
      {
        "<leader>cb",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Breadcrumb picker",
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
 ____                              _   _       _
/ ___|  __ _ _   _ _ __ __ ___   _| \ | |_   _(_)_ __ ___
\___ \ / _` | | | | '__/ _` \ \ / /  \| \ \ / / | '_ ` _ \
 ___) | (_| | |_| | | | (_| |\ V /| |\  |\ V /| | | | | | |
|____/ \__,_|\__,_|_|  \__,_| \_/ |_| \_| \_/ |_|_| |_| |_|
                 DEVOPS  SRE  CLOUD  CODE
]],
        },
      },
      explorer = { enabled = true },
      image = { enabled = false },
      notifier = { enabled = true, timeout = 3000 },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            exclude = { ".git", ".cache", ".next", ".nuxt", ".pytest_cache", ".ruff_cache", "build", "dist", "node_modules", "target" },
          },
          files = {
            hidden = true,
            ignored = true,
            exclude = { ".git", ".cache", ".next", ".nuxt", "node_modules", "target" },
          },
          grep = {
            hidden = true,
            ignored = true,
            exclude = { ".git", ".cache", ".next", ".nuxt", "node_modules", "target" },
          },
        },
      },
      terminal = { enabled = true },
    },
    keys = {
      {
        "<leader>uC",
        function()
          require("config.theme").select()
        end,
        desc = "Select theme",
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
        diagnostics = "nvim_lsp",
        separator_style = "slant",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "│", right = "│" },
      })
    end,
  },
}
