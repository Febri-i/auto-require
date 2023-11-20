# Auto require

I dont know if anyone need this but i like to organize my config file to multiple file according to what they actually do. The problem was that i need to require each config file its just pain and not-so organized. And i need to make sure that those file are required or when i want to delete a config file i need to make sure that the require statement is also deleted. I know i can use ```plugin``` folder but no its a config file not a plugin.

### Installation

Using Lazy.vim:

```lua
{
    "Febri-i/auto-require",
    opts = {...}
}

```

### Configuration

You may only need to add your config folders in ```dir_list```

```lua
{
	-- Path to that lua folder in your config, you mostly dont need to change it. Make sure its ended in that lua folder or else it will throw an error
	lua_root = "~/.config/nvim/lua",
	-- configuration directory relative to lua_root. eg: { "configs" }
	dir_list = {},
	-- require path that you want to ignore, can be a directory or a file eg: { "configs.dontrequire" }
	excludes = {},
}
```

### Example

Lets say i have my config folder like so:


```
.
└── ~/.config/nvim/
    └── lua/
        ├── configs/
        │   ├── dont_require_this/
        │   │   └── config.lua
        │   ├── anotherfolder/
        │   │   ├── not_this.lua
        │   │   └── but_this.lua
        │   └── config2.lua
        └── someother/
            └── config3.lua
```

and i want to require all config file from ```configs```, and ```someother``` except all the files from lua/configs/dont_require_this lua/configs/anotherfolder/not_this.lua my configuration would be


```lua
require("auto-require").setup({
	dir_list = { "configs", "someother" },
	excludes = {
		"configs.dont_require_this",
		"configs.anotherfolder.not_this",
	},
})
```
