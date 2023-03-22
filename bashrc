```sh
# .bashrc

# Source global definitions
#if [ -f /etc/bashrc ]; then
#	. /etc/bashrc
#fi

# User specific aliases and functions

alias ls='ls -lahFG'
export LC_NUMERIC=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# This makes the system reluctant to wipe out existing files via cp and mv
set -o noclobber
```
