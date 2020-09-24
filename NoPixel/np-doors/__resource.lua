resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

dependency "np-base"
dependency "ghmattimysql"


client_script "@np-errorlog/client/cl_errorlog.lua"

shared_script "shared/sh_doors.lua"

server_script "server/sv_doors.lua"
client_script "client/cl_doors.lua"

server_export 'isDoorLocked'