#!/bin/bash

# taken from blog post: http://www.mokacoding.com/blog/automatic-xcode-versioning-with-git/
# Automatically sets version of target based on most recent tag in git
# Automatically sets build number to number of commits
#
# Add script to build phase in xcode at the top of the chain named "set build number"
# put this script in the root of the xcode project in a directory called scripts (good idea to version control this too)
# call the script as $SRCROOT/scripts/set_build_number.sh in xcode

git=$(sh /etc/profile; which git)
number_of_commits=$("$git" rev-list HEAD --count)
git_release_version=$("$git" describe --tags --always --abbrev=0)

# $TARGET_BUILD_DIR = ~/Library/Developer/Xcode/DerivedData/Tinodios-eqpxjmfeshykdhenvfigilydnzgz/Build/Products/Debug-iphonesimulator
# $INFOPLIST_PATH = Tinodios.app/Info.plist
target_plist="$TARGET_BUILD_DIR/$INFOPLIST_PATH"
# $DWARF_DSYM_FOLDER_PATH = ~/Library/Developer/Xcode/DerivedData/Tinodios-eqpxjmfeshykdhenvfigilydnzgz/Build/Products/Release-iphoneos
# $DWARF_DSYM_FILE_NAME = Tinodios.app.dSYM
dsym_plist="$DWARF_DSYM_FOLDER_PATH/$DWARF_DSYM_FILE_NAME/Contents/Info.plist"

for plist in "$target_plist" "$dsym_plist"; do
  if [ -f "$plist" ]; then
    echo "Modifying '$plist'"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $number_of_commits" "$plist"
    echo "Assigned '$number_of_commits' to :CFBundleVersion"
    # Disabled for now. Apple wants versions like 1.2.3. Can't use tag name just yet.
    # /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${git_release_version#*v}" "$plist"
  fi
done
