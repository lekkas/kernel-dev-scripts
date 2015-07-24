#!/usr/bin/env bash

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

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

# Clone dotfiles from github
cd /home/"$USER"
git clone https://github.com/lekkas/dotfiles.git
cd dotfiles.git
/bin/bash dotfiles.git/makesymlinks.sh

