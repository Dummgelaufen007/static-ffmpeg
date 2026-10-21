package docker

default allow := true

default deny_msg := []

git_without_commit if {
	input.git
	not input.git.isCommitRef
}

allow := false if git_without_commit

deny_msg := [sprintf("git source %s is not pinned to a commit", [input.git.remote])] if git_without_commit

decision := {"allow": allow, "deny_msg": deny_msg}
