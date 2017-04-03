#!/bin/sh

#  EnsurePATH.sh
#  ErlangInstaller
#
#  Created by Sergio Abraham on 4/3/17.
#  Copyright © 2017 Erlang Solutions. All rights reserved.

cd ~
ERLANG_DEFAULT_PATH="~/.erlangInstaller/default"
if [ -f .bash_profile ]; then CONFIG_FILE=".bash_profile";
else
CONFIG_FILE=".profile";
fi
if ! grep -q $ERLANG_DEFAULT_PATH $CONFIG_FILE; then
printf "\n#ErlangInstaller\nexport PATH=\"$ERLANG_DEFAULT_PATH:\$PATH\"" >> $CONFIG_FILE
echo "Done.";
fi
