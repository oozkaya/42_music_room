#!/bin/bash                                                                                                                                                                                     

REPOSITORY_AUTHOR="spotify"
REPOSITORY_NAME="ios-sdk"

SPOTIFY_IOS_FRAMEWORK_VERSION="1.2.2"
RELEASE_TAG="v$SPOTIFY_IOS_FRAMEWORK_VERSION"

SPOTIFY_SDK_RELEASE_URL="https://github.com/spotify/ios-sdk/archive/$RELEASE_TAG.zip"

CURDIR=`dirname "$0"`

TMP_ZIP_DESTINATION="/tmp/$RELEASE_TAG.zip"
TMP_FRAMEWORK_FOLDER="/tmp/ios-sdk-$SPOTIFY_IOS_FRAMEWORK_VERSION/SpotifyiOS.framework"
SPOTIFY_SDK_DESTINATION="$CURDIR/../ios/Pods"

get_ios_sdk() {
    echo -e "\033[33m   * get ios framework\033[39m"
    
    echo -n "- Downloading spotify-ios-sdk $RELEASE_TAG > $SPOTIFY_SDK_DESTINATION"
    
    curl -sL $SPOTIFY_SDK_RELEASE_URL > $TMP_ZIP_DESTINATION && \
        mkdir -p $TMP_FRAMEWORK_FOLDER && \
        unzip -q -o $TMP_ZIP_DESTINATION -d /tmp && \
        rsync -K -a $TMP_FRAMEWORK_FOLDER $SPOTIFY_SDK_DESTINATION && \
        echo " ✅ " || \
        echo " ❌ Fail - Please check manually"
}

check_latest_release() {
    echo -e "\n\033[33m   * check lastest release\033[39m"

    URL="https://api.github.com/repos/$REPOSITORY_AUTHOR/$REPOSITORY_NAME/releases/latest"
    LAST_RELEASE=$(curl -s $URL | jq -r .tag_name)
    echo -n $LAST_RELEASE

    if [ "$LAST_RELEASE" == "$RELEASE_TAG" ]; then
        echo -e " ✅\nYou have the latest release"
    else
        echo -e " 🟡\nYou are not up to date. The latest release is $LAST_RELEASE"
        echo "Please check the new release: $URL"
    fi
}

get_ios_sdk
check_latest_release
