function ctrlc
    if count $argv > /dev/null
        echo $argv | xclip -selection clipboard
    else
	    xclip -selection clipboard
    end
end
