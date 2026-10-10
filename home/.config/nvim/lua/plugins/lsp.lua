return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      -- Trim/extend this list to match what you actually use.
      -- marksman + texlab cover your writing filetypes too.
      ensure_installed = {
        "lua_ls",
        "pyright",
        "clangd",
        "rust_analyzer",
        "gopls",
        "bashls",
        "jsonls",
        "marksman", -- markdown
        "texlab", -- latex
      },
      automatic_installation = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("lspconfig") -- loads nvim-lspconfig's bundled server definitions
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        -- requiring telescope.builtin lazy-loads telescope itself if it
        -- isn't already loaded, no extra wiring needed
        local tb = function(picker)
          return function() require("telescope.builtin")[picker]() end
        end
        map("n", "gd", tb("lsp_definitions"), "Go to definition")
        map("n", "gr", tb("lsp_references"), "References")
        map("n", "gi", tb("lsp_implementations"), "Go to implementation")
        map("n", "<leader>ds", tb("lsp_document_symbols"), "Document symbols")
        map("n", "<leader>ws", tb("lsp_dynamic_workspace_symbols"), "Workspace symbols")
        map("n", "K", vim.lsp.buf.hover, "Hover docs")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>d", vim.diagnostic.open_float, "Line diagnostics")
      end

      -- New Neovim 0.11+ native LSP config API. mason-lspconfig installs
      -- the binaries; this just tells nvim how/when to start each one.
      -- '*' applies shared defaults to every server below.
      vim.lsp.config("*", {
        capabilities = capabilities,
        on_attach = on_attach,
      })

      local servers = {
        "lua_ls", "pyright", "clangd",
        "rust_analyzer", "gopls", "bashls", "jsonls",
        "marksman", "texlab",
      }
      vim.lsp.enable(servers)
    end,
  },
}
