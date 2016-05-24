#!/bin/sh

zip -r budavar_web.zip ./ -x "archive/*" ".git/*" *.txt *.md LICENSE export.sh
