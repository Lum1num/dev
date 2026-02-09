-- choose client (client 2 is yourself, client 1 is luminum which is me.)
-- to enable ding (whenever someone chats so you'll get notified), set ding to true.
getgenv().client = 1
getgenv().ding = false

if getgenv().clientisactive then end

getgenv().clientisactive = true

local function fetch(var)
    return (game:HttpGet('https://raw.githubusercontent.com/Lum1num/dev/refs/heads/main/'..var):gsub('\n',''))
end

local cloneref = (cloneref or clonereference) or function(obj)
    return obj
end
local httpService = cloneref(game:GetService('HttpService'))
local soundService = cloneref(game:GetService('SoundService'))
local debrisService = cloneref(game:GetService('Debris'))
local playersService = cloneref(game:GetService('Players'))

local lplr = playersService.LocalPlayer

if not isfolder('client'..getgenv().client) then
    makefolder('client'..getgenv().client)
end
if not isfile('client'..getgenv().client..'/ding.mp3') then
    writefile('client'..getgenv().client..'/ding.mp3', fetch('ding.mp3'))
end
local function ding()
    if not getgenv().ding then return end
    local sound = Instance.new('Sound')
    debrisService:AddItem(sound, 5)
    sound.Parent = soundService
    sound.Volume = 0.35
    sound.SoundId = getcustomasset('client'..getgenv().client..'/ding.mp3')
    sound:Play()
    return sound
end

local clients = {
    ['1'] = { hookurl = fetch('client1') },
    ['2'] = { hookurl = fetch('client2') }
}
local client, clientid = clients[tostring(getgenv().client)].hookurl, getgenv().client

local request = request or (syn and syn.request) or function(tbl)
    warn('Your executor does not support request')
end

local function getico(id)
    local url = 'https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds='..id..'&size=420x420&format=Png&isCircular=false'
    local urldata = httpService:JSONDecode(game:HttpGet(url))
    return (urldata.data and urldata.data[1] and urldata.data[1].imageUrl) or ''
end

local function makedebug(msg)
    print('client '..clientid..': '..msg)
end

local function createmessage(message, user, icoid)
    if not request then return end
    local suc, res = pcall(function()
        request({
            Url = client,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = httpService:JSONEncode({
                content = tostring(message),
                username = (typeof(user) == 'Instance' and user == lplr and tostring(user.Name)..' (current client)' or (typeof(user) == 'Instance' and tostring(user.Name)..' (other client)' or tostring(user))),
                avatar_url = getico(icoid)
            })
        })
    end)
    if not suc and (res and res ~= '') then
        warn('falied to send on client '..getgenv().client..': '..tostring(res))
    end
end

local function createsimplified(user, message)
    createmessage(message, user.Name..(user.Name ~= user.DisplayName and '('..user.DisplayName..')' or ''), user.UserId)
end

local function createchatconnection(user)
    getgenv()[user.UserId] = user.Chatted:Connect(function(msg)
        task.delay(math.random(0.25,0.50), function()
            createsimplified(user, tostring(msg))
            if user ~= lplr then
                ding()
            end
        end)
    end)    
end
createchatconnection(lplr)
for _, plr in ipairs(playersService:GetPlayers()) do
    if plr ~= lplr then
        createchatconnection(plr)
        makedebug('connected: '..plr)
    end
end
playersService.PlayerAdded:Connect(function(plr)
    task.wait(0.25)
    createchatconnection(plr)
    makedebug('connected: '..plr)
end)
playersService.PlayerRemoving:Connect(function(plr)
    getgenv()[plr.UserId]:Disconnect()
    getgenv()[plr.UserId] = nil
    makedebug('disconnected: '..plr)
end)
-- created by luminum and just for fun :>
