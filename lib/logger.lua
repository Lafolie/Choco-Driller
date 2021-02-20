--[[
	To-Do:
		- UTF-8 support
		- auto-delete old logs (configurable) [done!]
		- automatic flushing [done!]
		- I/O thread
		- Pretty HTML output [done!]
		- JS filtering thereof
]]

-------------------------------------------------------------------------------
-- Setup
-------------------------------------------------------------------------------

local insert = table.insert

local Logger = setmetatable({}, 
{
	-- __call = function(t, name, config)
	--	 t.name = name
	--	 t.config = config or Logger:mkConfig()
	-- end
})

local initTime = love.timer.getTime()
local allLogs = {}
local activeLog

--ensure that subdir exists
if not love.filesystem.getInfo("logs/", "directory") then
	assert(love.filesystem.createDirectory "logs", "Could not find/create logs directory!")
	print "Created logs/ directory."
end

local logMeta = "logs/.logmeta"
if love.filesystem.getInfo(logMeta, "file") then
	local meta = {}
	for line in love.filesystem.lines(logMeta) do
		insert(meta, line)
	end
	logMeta = meta
else
	love.filesystem.write(logMeta, "")
	logMeta = {}
end

local hasInit

-------------------------------------------------------------------------------
-- API
-------------------------------------------------------------------------------
function Logger:init(name, config)
	-- assert(not hasInit, "Attempt to call Logger:init more than once!")
	if hasInit then
		Logger.flushAll()
	end
	hasInit = true

	self.name = name
	config = config or self:mkConfig()
	self.config = config
	-- insert(allLogs, self)

	--generate shortcut functions, i.e. Logger:echo()
	for k, v in pairs(config.logLevel) do
		Logger[k] = function(self, str, ...)
			self:print(v[1], str, ...)
	
			if #self > config.flushThreshold then
				self:flushAll()
			end
		end
	end

	local time = os.date("%d-%m-%Y %H-%M-%S", os.time())
	activeLog = string.format("logs/%s %s.%s", self.name, time, self.config.noHTML and "log" or "html")

	insert(logMeta, activeLog)
	while #logMeta > self.config.maxOldLogs do
		if love.filesystem.getInfo(logMeta[1], "file") then
			love.filesystem.remove(logMeta[1])
		end
		table.remove(logMeta, 1)
	end
	local str = table.concat(logMeta, "\n")
	love.filesystem.write("logs/.logmeta", str)
end

function Logger:clear()
	for n = #self, 1, -1 do
		self[n] = nil
	end
end

function Logger:getLogLevels()
	local t = {}
	for k, v in pairs(self.config.logLevel) do
		insert(t, v[1])
	end
	return t
end

function Logger:mkConfig()
	return
	{
		--log will be flushed when the number of lines exceeds this value
		flushThreshold = 1024,

		--whether old logs should be removed (see maxOldLogs)
		autoDelete = true,

		--keep only the last maxOldLogs logs, auto-delete older logs
		maxOldLogs = 5,

		--if true, files are written as plaintext
		noHTML = false,

		--feel free to edit log levels, related functions are dynamically bound to this list
		--first element is display string, second element is HTML output color
		logLevel = 
		{
			echo = {"Echo", "#aaaaaa"},
			warn = {"Warning", "#dddd22"},
			error = {"Error!", "#ff44aa"},
			info = {"Info", "#2288dd"},
			edit = {"Editor", "#88ddbb"},
			client = {"NetClient", "#aaaaaa"},
			server = {"NetServer", "#aaaaaa"},
		},
	}
end

function Logger:print(level, str, ...)
	str = string.format(str, ...)
	local time = love.timer.getTime() - initTime
	local timef = os.date("%H:%M:%S:", time)
	local logStr = string.format("[%s%03d] [%s] (%s) %s", timef, (time * 1000) % 1000, self.name, level, str)
	print(logStr)
	insert(self, logStr)
	return str
end

-- function Logger:echo(str, ...)
-- 	return self:print(logLevel.echo, str, ...)
-- end

function Logger:flushPlaintext()
	-- print("Flushing log", self.name)
	if #self == 0 then return end

	local succ, msg = love.filesystem.append(activeLog, table.concat(self, "\n"))
	if succ then
		print(string.format("Saved %s to %s", self.name, activeLog))
	else
		print(string.format("Error saving %s Logger:\n\t%s", self.name, msg))
	end
end

function Logger:toHTML(line)
	local html = [[
		<p>
			<span class="time">%s</span>&nbsp;<span class="name">%s</span>&nbsp;<span class="%s">%s&nbsp;%s</span>
		</p>]]
	local stamp, name, level, str = line:match("^(%[.+%])%s(%[.+%])%s(%(.+%))%s(.*)")
	return html:format(stamp, name, level:match("%(?(%a*)%)?"), level, str)

end

function Logger:flushHTML()
	-- print("Flushing log", self.name)
	if #self == 0 then return end
	local html = {}

	if not love.filesystem.getInfo(activeLog) then
		local headA =
		[[
<!DOCTYPE html>
<html>
	<head>
		<style>
			body
			{
				background-color: #08080a;
				color: #aaaaaa;
			}

			h1
			{
				color: #aaaaff;
			}

			p
			{
				background-color: #21212a;
				font-family: 'Monospace';
				padding-top: .1em;
				padding-bottom: .1em;
				margin: .25em;
			}

			.time
			{
				color: #22dd88;
			}

		]]

		--generate log level css
		local headB = {}
		local levelCSS = 
		[[
			.%s
			{
				color: %s;
			}
		]]
		for k, level in pairs(self.config.logLevel) do
			insert(headB, levelCSS:format(level[1]:match("(%a+)"), level[2]))
		end
		headB = table.concat(headB, "\n")

		local headC = 
		[[
		</style>
	</head>
	<body>
		<h1>%s</h1>
		]]

		insert(html, headA)
		insert(html, headB)
		insert(html, headC:format(activeLog))
	else
		local str = love.filesystem.read(activeLog)
		insert(html, str:match("(.*)</body>.*$"))
	end

	for k, v in ipairs(self) do
		insert(html, self:toHTML(v))
	end

	local tail = 
	[[
	</body>
</html>
	]]
	insert(html, tail)

	local succ, msg = love.filesystem.write(activeLog, table.concat(html, "\n"))
	if succ then
		print(string.format("Saved %s log to '%s/%s'", self.name, love.filesystem.getSaveDirectory(), activeLog))
	else
		print(string.format("Error saving %s Logger:\n\t%s", self.name, msg))
	end
end

function Logger.flushAll()
	-- for _, log in ipairs(allLogs) do
	-- 	usePlaintext and log:flushPlaintext() or log:flushHTML()
	-- end


	if Logger.config.noHTML then
		Logger:flushPlaintext()
	else
		Logger:flushHTML()
	end

	Logger:clear()
end

return Logger