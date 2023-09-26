#!/bin/sh
export NNN_BMS='D:~/Documents;l:/home/arya/Private/Lectures/;d:~/Downloads/;m:/run/media/arya;g:/run/user/1000/gvfs;t:~/.local/share/Trash/files;s:~/Pictures/Screenshots'
export NNN_SSHFS="sshfs -o follow_symlinks"        # make sshfs follow symlinks on the remote
export NNN_COLORS="21365798"                           # use a different color for each context
export NNN_TRASH=1                                 # trash (needs trash-cli) instead of delete
export EDITOR=~/.config/nnn/actions/editor
export NNN_PLUG='m:mount;p:preview-tabbed;s:subtitles.sh;d:dragdrop;e:edit'
export NNN_FIFO=/tmp/nnn.fifo
#nnn -x
