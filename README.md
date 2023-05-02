# cmp-gitcommit

`gitcommit` source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

`cmp-gitcommit` is a fork of [cmp-cgitcommit](https://github.com/Cassin01/cmp-gitcommit)
which in turn is a fork of [cmp-conventionalcommits](https://github.com/davidsierradz/cmp-conventionalcommits)

## Features

### Features that cmp-gitcommit provides but cmp-conventionalcommits

- no npm dependencies
- no emojis
- works in more places on the first line

### Features that cmp-conventionalcommits provides but cmp-gitcommit

- commitlint support
- lerna support

### Sources that this plugin provides

This plugin provides

- types (`ci`, `fix`, `feat` etc)
- scopes (`Travis`, `Circle`, `BrowserStack`, etc)
- tracked path object (`README.md`, `src`, `.gitignore`, etc)

sources for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

## Usage

Lazy

```lua
{
    "michaelrommel/cmp-gitcommit",
    lazy = true,
    config = function()
        require("cmp-gitcommit").setup({})
    end,
},
```

```lua
require('cmp').setup {
  sources = require'cmp'.config.sources({{ name = 'gitcommit' }})
}
```

## Configuration

```lua
use {
   -- ...
   config = function()
     require('cmp-gitcommit').setup({
       typesDict = {
         ci = {
           label = 'ci',
           documentation = 'Changes to our CI configuration files and scripts',
           scopes = {'Travis', 'Circle', 'BrowserStack', 'SauceLabs'} -- FEATURE custom scopes !!
         }
         style = {
           label = 'style',
           documentation = 'Changes that do not affect the meaning of the code',
         }
         test = {
           label = 'test',
           documentation = 'Adding missing tests or correcting existing tests',
         }
         -- ...
       }
       insertText = function(label, emoji) return label .. ":" .. emoji .. ' ' end
     })
   end
}
```
