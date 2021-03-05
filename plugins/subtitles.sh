#!/usr/bin/env bash

XDOTOOL_TIMEOUT=2
PAGER=${PAGER:-"nvim -R"}
NUKE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/plugins/nuke"

TERMINAL="st -w"


term_nuke () {
    # $1 -> $XID, $2 -> $FILE
    $TERMINAL "$1" -e "$NUKE" "$2" &
}

start_tabbed () {
    FIFO="$(mktemp -u)"
    mkfifo "$FIFO"

    # tabbed > "$FIFO" &

    jobs # Get rid of the "Completed" entries

    TABBEDPID="$(jobs -p %%)"

    if [ -z "$TABBEDPID" ] ; then
        echo "Can't start tabbed"
        exit 1
    fi

    read -r XID < "$FIFO"

    rm "$FIFO"
}

get_viewer_pid () {
        VIEWERPID="$(jobs -p %%)"
}

kill_viewer () {
        if [ -n "$VIEWERPID" ] && jobs -p | grep "$VIEWERPID" ; then
            kill "$VIEWERPID"
        fi
}

sigint_kill () {
	kill_viewer
	kill "$TABBEDPID"
	exit 0
}

previewer_loop () {
    notify-send "$NNN_FIFO"
    unset -v NNN_FIFO
    # mute from now
    exec >/dev/null 2>&1

    MAINWINDOW="$(xdotool getactivewindow)"

    # start_tabbed
    # trap sigint_kill SIGINT

    # xdotool windowactivate "$MAINWINDOW"

    # Bruteforce focus stealing prevention method,
    # works well in floating window managers like XFCE
    # but make interaction with the preview window harder
    # (uncomment to use):
    #xdotool behave "$XID" focus windowactivate "$MAINWINDOW" &

    while read -r FILE ; do

        jobs # Get rid of the "Completed" entries

        if ! jobs | grep tabbed ; then
            break
        fi

        if [ ! -e "$FILE" ] ; then
            continue
        fi

        kill_viewer

        MIME="$(file -b --mime-type "$FILE")"

        case "$MIME" in
            video/*)
                emacsclient "${FILE%.*}".vtt
                ;;
            audio/*)
                # if which mpv >/dev/null 2>&1 ; then
                #     mpv --force-window=immediate --loop-file --wid="$XID" "$FILE" &
                # else
                #     term_nuke "$XID" "$FILE"
                # fi
                ;;
            image/*)
                # if which sxiv >/dev/null 2>&1 ; then
                #     sxiv -e "$XID" "$FILE" &
                # else
                #     term_nuke "$XID" "$FILE"
                # fi
                ;;
            application/pdf)
                # if which zathura >/dev/null 2>&1 ; then
                #     zathura -e "$XID" "$FILE" &
                # else
                #     term_nuke "$XID" "$FILE"
                # fi
                ;;
            inode/directory)
                # $TERMINAL "$XID" -e bash -c "tree -L 2 \"$FILE\" | less" &
                ;;
            text/*)
                # if [ -x "$NUKE" ] ; then
                #     term_nuke "$XID" "$FILE"
                # else
                #     # shellcheck disable=SC2086
                #     $TERMINAL "$XID" -e $PAGER "$FILE" &
                # fi
                ;;
            *)
                # if [ -x "$NUKE" ] ; then
                #     term_nuke "$XID" "$FILE"
                # else
                #     $TERMINAL "$XID" -e sh -c "file '$FILE' | $PAGER -" &
                # fi
                ;;
        esac
        get_viewer_pid

        # following lines are not needed with the bruteforce xdotool method
        ACTIVE_XID="$(xdotool getactivewindow)"
        # if [ $((ACTIVE_XID == XID)) -ne 0 ] ; then
        #     xdotool windowactivate "$MAINWINDOW"
        # else
        #     timeout "$XDOTOOL_TIMEOUT" xdotool behave "$XID" focus windowactivate "$MAINWINDOW" &
        # fi
    done
    kill "$TABBEDPID"
    kill_viewer
}

if [ ! -r "$NNN_FIFO" ] ; then
    echo "Can't read \$NNN_FIFO ('$NNN_FIFO')"
    exit 1
fi

previewer_loop < "$NNN_FIFO" &
disown

