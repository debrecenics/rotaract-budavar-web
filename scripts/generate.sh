#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET=$DIR/temp
LOG=$DIR/log.log

LANGAUGES="hu_HU,en_GB,es_ES,de_DE"
DEFAULT_LANGUAGE="hu"
MENUS="index,about,timeline,gallery,documents,contact,roundtrip"
HIGHLIGHTED_MENU="roundtrip"
PAGES="index,about,timeline,gallery,documents,contact,roundtrip,roundtrip_info,roundtrip_register"

DEFAULT_IFS="@"

function timestamp {
  # returns the current time
  date +"%Y-%m-%d_%H-%M-%S"
}

rm -rf $LOG
function log {
  # append the current time and $1 arg to the log file
  echo "$(timestamp) $1" 1>>$LOG
}

function prepareWorkspace {
  if [ ! -d $TARGET ]; then
      mkdir $TARGET
  fi
  rm -rf $TARGET/*
  cp $DIR/../css $TARGET/css -r
  cp $DIR/../js $TARGET/js -r
  cp $DIR/../images $TARGET/images -r
  cp $DIR/../gallery $TARGET/gallery -r
  cp $DIR/../docs $TARGET/docs -r
}

function toUpper {
  echo "$1" | PERLIO=:utf8 perl -pe '$_=uc'
}

function capitalize {
  echo "$1" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2)) }'
}

function trim {
  echo -e "${1}" | tr -d '[[:space:]]'
}

function relativePath {
  if [ "$1" == "$DEFAULT_LANGUAGE" ]; then
    relativePath=""
  else
    relativePath="../"
  fi
  echo $relativePath
}

function getContent {
  page=$1
  lang=$2
  langSelect=$3
  menuSelect=$4

  # Load for getting Parent value
  . $DIR/skeleton/$lang/$page.sh
  NAVIGATION=$(trim $NAVIGATION)
  if [ "$NAVIGATION" == "yes" ]; then
    log "Navigation bar is calculating"
    # Load for getting the name for Parent
    PARENT=$(trim $PARENT)
    log "Parent is $DIR/skeleton/$lang/$PARENT.sh file."
    . $DIR/skeleton/$lang/$PARENT.sh
    # Set the parent name
    PARENT_NAME="$NAME"
    log "Parent is $PARENT_NAME name."
    # Reload for getting the other values
    . $DIR/skeleton/$lang/$page.sh
    # Load Navigator part to the content
    . $DIR/skeleton/navigator.sh
    content=$NAVIGATOR
  else
    log "No navigation bar is required"
    content=$CONTENT
  fi
  relPath=$(relativePath $lang)
  . $DIR/skeleton/body.sh
  echo $BODY
}

function getMenuSelect {
  page=$1
  lang=$2

  # Iterate over languages
  local OLD_IFS=$IFS
  IFS=','
  read -r -a menus <<< "$MENUS"
  for menu in "${menus[@]}"
  do
    # Load page for menu
    . $DIR/skeleton/$lang/$menu.sh
    UPPER_NAME=$(toUpper $NAME)
    if [ "$menu" == "$HIGHLIGHTED_MENU" ]; then
      echo "<li class=\"top-contact\"><a href=\"$menu.html\">$UPPER_NAME</a></li>"
    elif [ "$page" == "$menu" ]; then
      echo "<li class=\"active\"><a href=\"$menu.html\">$UPPER_NAME</a></li>"
    else
      echo "<li><a href=\"$menu.html\">$UPPER_NAME</a></li>"
    fi
  done
  IFS=$OLD_IFS
}

function getLangSelect {
  page=$1
  lang=$2

  relPath=$(relativePath $lang)

  # Iterate over languages
  local OLD_IFS=$IFS
  IFS=','
  read -r -a array <<< "$LANGAUGES"
  for language in "${array[@]}"
  do
    language=$(echo "$language" | cut -c1-2)
    if [ "$language" == "$DEFAULT_LANGUAGE" ]; then
      echo "<a href=\"$relPath$page.html\"><span class=\"$language\"></span></a>"
    else
      echo "<a href=\"$relPath$language/$page.html\"><span class=\"$language\"></span></a>"
    fi
  done
  IFS=$OLD_IFS
}

function setOutputFile {
  page=$1
  lang=$2

  if [ "$lang" == "$DEFAULT_LANGUAGE" ]; then
    location="$TARGET/$page.html"
  else
    location="$TARGET/$lang/$page.html"
    if [ ! -d "$TARGET/$lang" ]; then
        mkdir "$TARGET/$lang"
    fi
  fi
  log "Output: $location"
  echo $location
}

# Parameters: $1 - name of the page
#             $2 - lang of the page
function generatePageInLanguage {

  page=$1
  lang=$2
  simple_lang=$(echo "$lang" | cut -c1-2)
  relPath=$(relativePath $simple_lang)

  outputFile=$(setOutputFile $page $simple_lang)
  langSelect=$(getLangSelect $page $simple_lang)
  menuSelect=$(getMenuSelect $page $simple_lang)

  local OLD_IFS=$IFS
  IFS="$DEFAULT_IFS"

  log "get content $page $simple_lang"
  BODY=$(getContent $page $simple_lang $langSelect $menuSelect)


  . $DIR/skeleton/facebook.sh
  . $DIR/skeleton/footer.sh
  . $DIR/skeleton/header.sh

  echo $HEADER > $outputFile
  echo $FACEBOOK_SCRIPT >> $outputFile
  echo $BODY >> $outputFile
  echo $FOOTER >> $outputFile

  IFS=$OLD_IFS

}

# Parameters: $1 - name of the page
function generatePage {
  page=$1
  # Iterate over languages
  local OLD_IFS=$IFS
  IFS=','
  read -r -a array <<< "$LANGAUGES"
  for language in "${array[@]}"
  do
      log "generatePageInLanguage $page $language"
      generatePageInLanguage $page $language
  done
  IFS=$OLD_IFS
}

function generatePages {
  # Iterate over pages
  local OLD_IFS=$IFS
  IFS=','
  read -r -a array <<< "$PAGES"
  for page in "${array[@]}"
  do
      log "generatePage $page"
      generatePage $page
  done
  IFS=$OLD_IFS
}

prepareWorkspace
generatePages
