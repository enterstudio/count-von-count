local args = ngx.req.get_uri_args()
args["date"] = os.date("%Y-%m-%d",ngx.req.start_time())
local cjson = require "cjson"
local args_json = cjson.encode(args)

-- todo: Move to initRedis func
local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000) -- 1 sec
red:connect("127.0.0.1", 6379)

ngx.say(args_json)
local ok, err = red:evalsha(ngx.var.redis_mobile_hash, 1, "args", args_json)
if ok then
	ngx.say(ok)
else
	ngx.say(err)
end

if ok then red:set_keepalive(10000, 100) end

-- ngx.exec('/_.gif')


