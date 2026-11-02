-- Narrower file explorer: snacks' sidebar layout defaults to 40 columns
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            layout = { layout = { width = 33, min_width = 33 } },
          },
        },
      },
    },
  },
}
