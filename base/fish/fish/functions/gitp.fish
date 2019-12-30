function gitp
	set branch (git rev-parse --abbrev-ref HEAD)
git remote | xargs -L1 -I REMOTE git push REMOTE $branch
end
