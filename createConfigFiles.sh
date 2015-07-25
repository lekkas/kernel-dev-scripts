#!/usr/bin/env bash

USER=$(whoami)

# Create .muttrc
MUTTRC=/home/"$USER"/.muttrc
cat << EOF > "$MUTTRC"
set envelope_from = yes
set edit_headers = yes

# Credentials
set from = "Kostas Lekkas <kwstasl@gmail.com>"
set use_from = yes
set ssl_force_tls = yes   # always use SSL
set smtp_url = "smtp://kwstasl@gmail.com@smtp.gmail.com:587/"
set smtp_pass = "notapassword"
set imap_user = "kwstasl@gmail.com"
set imap_pass = "notapassword"

set header_cache = "~/.mutt/cache/headers"
set message_cachedir = "~/.mutt/cache/bodies"
set certificate_file = "~/.mutt/certificates"

# IMAP
set folder = "imaps://imap.gmail.com:993"
set spoolfile = "+INBOX"
set postponed = "+[Google Mail]/Drafts"
mailboxes "+kernel/linux-kernel" "+kernel/eudyptula" "+kernel/netdev"
mailboxes "+INBOX ""+[Google Mail]/Sent Mail" "+[Google Mail]/Drafts"

set timeout = 300
set mail_check = 60

set move = no
set copy = no
set imap_keepalive = 900
set sort = reverse-date-received

bind editor <space> noop
macro index gi "<change-folder>=INBOX<enter>" "Go to inbox"
macro index gk "<change-folder>=kernel/linux-kernel<enter>" "Go to kernel"
macro index ge "<change-folder>=kernel/eudyptula<enter>" "Go to eudyptula"
macro index gs "<change-folder>=[Google Mail]/Sent Mail<enter>" "Go to sent"
EOF

chmod 600 "$MUTTRC"
touch /home/"$USER"/.mutt/certificates
mkdir -p /home/"$USER"/.mutt/cache

# Clone dotfiles from github and create symlinks for .vimrc, .bashrc etc
cd /home/"$USER"
git clone https://github.com/lekkas/dotfiles.git dotfiles.git
cd dotfiles.git
/bin/bash /home/"$USER"/dotfiles.git/makesymlinks.sh
