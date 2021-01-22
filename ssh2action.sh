#!/bin/bash

set -e

if [[ ! -z "$SKIP_DEBUGGER" ]]; then
    echo "Skipping debugger because SKIP_DEBUGGER enviroment variable is set"
    exit
fi

# Install tmate on macOS or Ubuntu
if [ -x "$(command -v apt-get)" ]; then
    curl -fsSL git.io/tmate.sh | bash
elif [ -x "$(command -v brew)" ]; then
    brew install tmate
else
    exit 1
fi

# Generate ssh key if needed
[ -e ~/.ssh/id_rsa ] || ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

# Run deamonized tmate
echo Running tmate...
tmate -S /tmp/tmate.sock new-session -d
tmate -S /tmp/tmate.sock wait tmate-ready

# Print connection info
tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}'
tmate -S /tmp/tmate.sock display -p '#{tmate_web}'

if [[ ! -z "$SLACK_WEBHOOK_URL" ]]; then
    MSG=$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}')
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"\`$MSG\`\"}" $SLACK_WEBHOOK_URL
fi
