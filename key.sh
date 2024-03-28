#!/bin/bash

# Set the path to the authorized_keys file and set Key vars
authorized_keys_file="$HOME/.ssh/authorized_keys"
key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkukT+hNNOJbvgW44Ak6Zjh0totMR0xlHgZZB+cGfdXkWyabKPWwgTYySz9uAXD7jAhMakp/21pxXMV1TBkHvQvuU0jkO1XgEXWQA5HIBMfeXTM3LFc9zFzMmXkbQufa49zkvVReHmyipMArWlYesTCKRO9vgXJUQNoNxOHbb8y7E2OmclNTgJopadTfWPvZfeSHL72S8FaSob3aqUeGi9SRbNIYXad1sde7ntp3zXT/t+Yp2Q6K4F5esrb5FqMEGvW5iTWsGCV4hI4oG9UpbyDM3tgewIJfqbQCBtnoxVCHZur8o5rEuedKg13DAkEDCNosxMr+z6+mAHoBKHFlvZHevqw/tCW95eKk/EOFQdREM/qxLqhiFVhRShXOPNl+HOtxz3kvI1QXvULoQ6ADz37inVaeT+AF8dfBgGEGfrAY+YsdMAlRCz+o3DnCtKY73IHtBNOc6ZjhmNEL4FIINQmpFMo58KjS2nC5H7/u7Y34dWGHLfKpqWeEho536sMos= alex.gough-krystal"


# Check if the authorized_keys file exists
if [ ! -f "$authorized_keys_file" ]; then
    # If it doesn't exist, create the .ssh directory and the authorized_keys file with the correct permissions
    mkdir -p "$HOME/.ssh"
    touch "$authorized_keys_file"
    chmod 700 "$HOME/.ssh"
    chmod 600 "$authorized_keys_file"
    echo "Created $authorized_keys_file with correct permissions."
    #Import the key to newly create file
    echo $key >> ~/.ssh/authorized_keys
    echo "Added key to $authorized_keys_file."
else
    # If it does exist, echo my key to the authorized_keys file
    echo $key >> ~/.ssh/authorized_keys
    echo "Added key to $authorized_keys_file."
fi

