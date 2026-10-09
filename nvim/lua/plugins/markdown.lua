return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      render_modes = true,
      debounce = 60,
      anti_conceal = { enabled = false },
      heading = {
        sign = false,
        position = "inline",
        icons = { "󰲡  ", "󰲣  ", "󰲥  ", "󰲧  ", "󰲩  ", "󰲫  " },
        width = "full",
        left_pad = 1,
        right_pad = 1,
      },
      code = {
        sign = false,
        width = "block",
        left_pad = 1,
        right_pad = 1,
        border = "thin",
        position = "right",
      },
      bullet = {
        icons = { "●", "○", "◆", "◇" },
        right_pad = 1,
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
        checked = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" },
      },
      quote = { icon = "▌" },
      pipe_table = { preset = "round" },
      win_options = {
        conceallevel = { default = 0, rendered = 2 },
        concealcursor = { default = "", rendered = "nivc" },
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    init = function()
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_combine_preview = 1
      vim.g.mkdp_combine_preview_auto_refresh = 1
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_page_title = "${name}"
    end,
  },
}
