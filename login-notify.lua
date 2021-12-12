BASE_URL = 'https://api.telegram.org/bot'
API_TOKEN = 'your_token'
SEND_MESSAGE_ENDPOINT = 'sendMessage'
CHAT_ID = 'your_chat_id'

function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

local function get_wan_ip()
    local line = os.capture('ip address show wan | egrep "inet\\s"', false)
    local start, stop = string.find(line, '%d+%.%d+%.%d+%.%d+')
    local ip_address = string.sub(line, start, stop)
    return ip_address
end

local log = os.capture('logread')
local matched_ips = {}
for ip in string.gmatch(log, '%d+%.%d+%.%d+%.%d+') do
    table.insert(matched_ips, ip)
end

LAST_LOGGED_IP = matched_ips[#matched_ips]

HOSTNAME = os.capture('uci get system.@system[0].hostname', false)
HOST_IP_ADDRESS = get_wan_ip()

TEXT = string.format('Someone logged in host=<code>%s</code> ip_address=<code>%s</code> source=<code>%s</code>', HOSTNAME, HOST_IP_ADDRESS, LAST_LOGGED_IP)

local url = string.format(
    '%s%s/%s?text=%s&chat_id=%s&parse_mode=%s',
    BASE_URL,
    API_TOKEN,
    SEND_MESSAGE_ENDPOINT,
    TEXT,
    CHAT_ID,
    'HTML'
)

os.execute(string.format('wget "%s"', url))
