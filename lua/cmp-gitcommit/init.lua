local source = {}

local typesDict = {}
typesDict['feat'] = {
	label = 'feat',
	emoji = '✨',
	documentation = 'A new feature'
}
typesDict['fix'] = {
	label = 'fix',
	emoji = '🐛',
	documentation = 'A bug fix'
}
typesDict['docs'] = {
	label = 'docs',
	emoji = '📚',
	documentation = 'Documentation only changes',
}
typesDict['style'] = {
	label = 'style',
	emoji = '💎',
	documentation =
	'Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)',
}
typesDict['refactor'] = {
	label = 'refactor',
	emoji = '📦',
	documentation = 'A code change that neither fixes a bug nor adds a feature',
}
typesDict['perf'] = {
	label = 'perf',
	emoji = '🚀',
	documentation = 'A code change that improves performance',
}
typesDict['test'] = {
	label = 'test',
	emoji = '🚨',
	documentation = 'Adding missing tests or correcting existing tests',
}
typesDict['build'] = {
	label = 'build',
	emoji = '🛠',
	documentation = 'Changes that affect the build system or external dependencies',
	scopes = { 'gulp, broccoli, npm' }
}
typesDict['ci'] = {
	label = 'ci',
	emoji = '⚙️',
	documentation = 'Changes to our CI configuration files and scripts',
	scopes = { 'Travis', 'Circle', 'BrowserStack', 'SauceLabs' }
}
typesDict['chore'] = {
	label = 'chore',
	emoji = '♻️',
	documentation = 'Other changes that dont modify src or test files',
}
typesDict['revert'] = {
	label = 'revert',
	emoji = '🗑',
	documentation = 'Reverts a previous commit',
}

function source.setup(config)
	local cnf = config or {}
	if cnf['typesDict'] == nil then
		cnf['typesDict'] = typesDict
	end
	if cnf['insertText'] == nil then
		cnf['insertText'] = function(label) return label end
	end
	vim.g.cmp_gitcommit_config = cnf
	return cnf
end

local function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

local function load_names()
	local current_dir_path = vim.fn.expand([[%:p:h:h]])
	if not vim.fn.isdirectory(current_dir_path) then
		return {}
	end
	local cmd = "(cd " .. current_dir_path .. " && git ls-files)"
	local handle = io.popen(cmd)
	local scopes = handle:read("*a")
	handle:close()

	local names = {}
	if scopes ~= "" then
		for line in scopes:gmatch("[^\r\n]+") do
			for _, name in ipairs(split(line, [[/]])) do
				table.insert(names, name)
			end
		end
	end

	local set = {}
	for _, name in ipairs(names) do
		set[name] = true
	end

	local candidates = {}
	for k, _ in pairs(set) do
		table.insert(candidates, k)
	end

	return candidates
end

source.new = function()
	source.config = vim.g.cmp_gitcommit_config or source.setup({})
	source.names = load_names()

	local types = {}
	for _, v in pairs(source.config['typesDict']) do
		table.insert(types, v)
	end
	source.types = types

	return setmetatable({}, { __index = source })
end

source.is_available = function()
	return vim.bo.filetype == 'gitcommit'
end

source.get_debug_name = function()
	return 'gitcommit'
end

source.get_keyword_pattern = function()
	return [[\w\+]]
end

local function is_scope(request)
	local line = vim.api.nvim_get_current_line()
	local col = request.context.cursor.col
	local char = line:sub(col, col)
	if char ~= nil and char == ')' then
		return true
	end
	return false
end

source.complete = function(self, request, callback)
	if (request.context.option.reason == 'manual' and request.context.cursor.row == 1 and request.context.cursor.col == 1) or
		(request.context.option.reason == 'auto' and request.context.cursor.row == 1 and request.context.cursor.col == 2) then
		callback({
			items = self:_get_candidates(self.types),
			isIncomplete = true,
		})
	elseif is_scope(request) and request.context.cursor.row == 1 then
		local line = vim.api.nvim_get_current_line()
		for k, _ in pairs(source.config['typesDict']) do
			local index = string.match(line, [[^(]] .. k .. [[).*]])
			if index ~= nil and self.config.typesDict[k].scopes ~= nil then
				return callback({
					items = self:_get_candidates_scope(self.config.typesDict[k].scopes),
					isIncomplete = true
				})
			end
		end
		callback()
	elseif request.context.option.reason == 'auto' then
		callback({
			items = self:_get_candidates_name(self.names),
			isIncomplete = true,
		})
	else
		callback()
	end
end

function source:_get_candidates(entries)
	local items = {}
	for k, v in ipairs(entries) do
		items[k] = {
			label = v.label,
			insertText = v.label,
			kind = require('cmp').lsp.CompletionItemKind.Keyword,
			documentation = v.documentation,
		}
	end
	return items
end

function source:_get_candidates_scope(entries)
	local items = {}
	for k, v in ipairs(entries) do
		items[k] = {
			label = v,
			documentation = 'scope',
			kind = require('cmp').lsp.CompletionItemKind.Folder,
		}
	end
	return items
end

function source:_get_candidates_name(entries)
	local items = {}
	for k, v in ipairs(entries) do
		items[k] = {
			label = v,
			documentation = 'tracked path object',
			kind = require('cmp').lsp.CompletionItemKind.File,
		}
	end
	return items
end

return source
