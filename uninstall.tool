#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "Insufficient permissions. Use sudo or root account." 1>&2
    exit 1
fi

my_default_prompt=0
if test "$#" != "0"; then
    if test "$#" != "1" -o "$1" != "--force"; then
        echo "Error: Unknown argument(s): $*"
        echo ""
        echo "Usage: uninstall.tool [--force]"
        echo ""
        echo "If the '--force' option is not given, you will be prompted"
        echo "for a Yes/No before doing the actual uninstallation."
        echo ""
        exit 4;
    fi
    my_default_prompt="Yes"
fi

if test "$my_default_prompt" != "Yes"; then
    echo "Do you wish to uninstall EslErlang (Yes/No)?"
    read my_answer
    if test "$my_answer" != "Yes"  -a  "$my_answer" != "YES"  -a  "$my_answer" != "yes"; then
        echo "Aborting uninstall. (answer: '$my_answer')".
        exit 2;
    fi
    echo ""
fi

echo "Removing files"

for  p in "com.erlang-solutions.Erlang" "com.erlang-solutions.MacUpdaterSwift"; do

    FILES=`/usr/sbin/pkgutil --files ${p} 2>/dev/null`
    for s in $FILES; do
        if [ -f "/${s}" -o -h "/${s}" ]; then
            rm "/${s}" #if s is dir it will not be removed
        fi
    done

#reverse order because when dir A has empty dir B then A cannot be removed, and by reversing
#we get the deepest directory first so everything works.

    DIRS=`/usr/sbin/pkgutil --files ${p} 2>/dev/null --only-dirs | awk '{x = $0 "\n" x} END {printf "%s", x}'`
    for d in $DIRS; do
        if [ -d "/${d}" ]; then
            rmdir "/${d}" 2>/dev/null
        fi
    done

    echo "Cleaning up"

    pkgutil --forget $p 2>/dev/null

done

osascript -e 'tell application "System Events" to delete login item "EslErlangUpdater"' 2>/dev/null
osascript -e 'tell application "System Events" to delete login item "MacUpdaterSwift"' 2>/dev/null



echo "Uninstallation completed"
