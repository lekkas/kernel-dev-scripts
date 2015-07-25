#!/usr/bin/env bash

USER=$(whoami)


# Clone dotfiles from github and create symlinks for .vimrc, .bashrc etc
cd /home/"$USER"
git clone https://github.com/lekkas/dotfiles.git dotfiles.git
cd dotfiles.git
/bin/bash /home/"$USER"/dotfiles.git/makesymlinks.sh

# Create .muttrc
MUTTRC=/home/"$USER"/.muttrc
cp dotfiles/.muttrc "$MUTTRC"
chmod 600 "$MUTTRC"
touch /home/"$USER"/.mutt/certificates
mkdir -p /home/"$USER"/.mutt/cache
