#!/bin/bash

projName=$(basename $(pwd))

function encrypt()
{
	mkdir "$projName"

	while read -r file
	do
		openssl enc -aes-256-cbc -salt -in "$file" -pass file:$HOME/enc.pass | base64 > "$file.enc.b64"
		cp --parents "$file.enc.b64" "$projName"
		mv "$projName/$file.enc.b64" "$projName/$file"
		rm "$file.enc.b64"
	done < <(find -type f ! -path '*./.git/*')
}

function decrypt()
{
	cd "$projName"

	while read -r file
	do
		base64 -d -i "$file" | openssl enc -d -aes-256-cbc -salt -pass file:$HOME/enc.pass > "$file.dec"
		mv "$file.dec" "$file"
	done < <(find -type f ! -path '*./.git/*')
}

function init()
{
	if [[ ! -e ".git/config" ]]; then
		hub init
		hub create
		if [[ ! -e "README" ]]; then
			echo "$projName" >> README
			echo "-------------------" >> README
		fi
		nano -w README LICENSE

#		find -type f ! -path *./.git/* -exec echo "#{}" \; >> .gitignore
#		fgrep -i -l * -R -e '-----BEGIN' >> .gitignore
#		nano -w .gitignore

		hub add .
		hub commit -a -m "null"
		hub push origin master
	fi
}

function update()
{
	nano -w README .gitignore

	hub add .
	hub commit -a -m "null"
	hub push origin master
}

function main()
{
	case "$command" in
		"update")
			update
		;;
		"init")
			init
		;;
		"encrypt")
			encrypt
		;;
		"decrypt")
			decrypt
		;;
		*)
			echo "Usage: git-encrypt.sh [ update | init | encrypt | decrypt ]"
		;;
	esac
}

command="$1"

main
