#!/usr/bin/env lua

function read_config(config, prefix)
	prefix = prefix or ""

	source_files = source_files or ""
	jar_dependencies = jar_dependencies or ""

	for k, v in pairs(config) do
		local string_rep = k .. ""
		
		if (string_rep:match("%a+%d*") == string_rep) then
			
      read_config(v, prefix .. k .. "/")
		
    elseif (string_rep:match("%d+") == string_rep) then
			
      if v:match("%a+%d*.scala") then
				
        source_files = source_files .. " " .. prefix .. v
			
      elseif v:match("%a+%d*.jar") then
        
        if (jar_dependencies ~= "") then
          jar_dependencies = jar_dependencies .. " "
        end
				
        jar_dependencies = jar_dependencies .. prefix .. v
			
      end
		
    end
	end
end

function mkdir(dirname)
  dirname = dirname or "(name)"

  os.execute("if [ ! -d '" .. dirname .. "' ]; then mkdir " .. dirname .. "; fi")
end

config_file, err = loadfile("BUILD")

if (config_file) then
	config = config_file()
else
	print(err)
	return
end

if (not config._main) then
  print("ERROR: please pick a main class")
  return
end

read_config(config)

mkdir("out")

mode = ...
mode = mode or "compile"

if (mode == "compile") then
	compile_command = "scalac -d out -classpath '" .. jar_dependencies .. "'" .. source_files
	os.execute(compile_command)
elseif (mode == "run") then
	run_command = "scala -cp out " .. config._main
	os.execute(run_command)
else
  print("ERROR: " .. mode .. " is not a valid mode")
  return
end
