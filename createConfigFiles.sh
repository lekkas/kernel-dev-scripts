#!/usr/bin/env bash

USER=$(whoami)

# .muttrc
MUTTRC=/home/"$USER"/.muttrc
cat << EOF > "$MUTTRC"
# Me
set envelope_from=yes
set edit_headers=yes

# Credentials
set from="John Doe <johndoe@gmail.com>"
set use_from=yes
set ssl_force_tls=yes
set smtp_url = "smtp://johndoe@gmail.com@smtp.gmail.com:587/"
set smtp_pass="notapassword"

set header_cache = "~/.mutt/cache/headers"
set message_cachedir = "~/.mutt/cache/bodies"
set certificate_file = "~/.mutt/certificates"
EOF

chmod 600 "$MUTTRC"
mkdir -p /home/"$USER"/.mutt/certificates
touch /home/"$USER"/.mutt/cache

# Clone dotfiles from github
cd /home/"$USER"
git clone https://github.com/lekkas/dotfiles.git dotfiles.git
cd dotfiles.git
/bin/bash /home/"$USER"/dotfiles.git/makesymlinks.sh
