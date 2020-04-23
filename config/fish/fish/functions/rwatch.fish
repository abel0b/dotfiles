function rwatch
	while inotifywait -r -e create -e delete -e modify $argv[0]
bash -c "$argv[2]"
end
end
