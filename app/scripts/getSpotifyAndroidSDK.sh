#!/bin/bash                                                                                                                                                                                     

REPOSITORY_AUTHOR="spotify"
REPOSITORY_NAME="android-sdk"

SPOTIFY_APP_REMOTE_VERSION="0.7.1"
SPOTIFY_AUTH_VERSION="1.2.3"
RELEASE_TAG="v$SPOTIFY_APP_REMOTE_VERSION-appremote_v$SPOTIFY_AUTH_VERSION-auth"

SPOTIFY_APP_REMOTE_RELEASE_URL="https://github.com/spotify/android-sdk/releases/download/v$SPOTIFY_APP_REMOTE_VERSION-appremote_v$SPOTIFY_AUTH_VERSION-auth/spotify-app-remote-release-$SPOTIFY_APP_REMOTE_VERSION.aar"
SPOTIFY_AUTH_RELEASE_URL="https://github.com/spotify/android-sdk/releases/download/v$SPOTIFY_APP_REMOTE_VERSION-appremote_v$SPOTIFY_AUTH_VERSION-auth/spotify-auth-release-$SPOTIFY_AUTH_VERSION.aar"                       

CURDIR=`dirname "$0"`

SPOTIFY_APP_REMOTE_DESTINATION="$CURDIR/../android/spotify-app-remote/spotify-app-remote.aar"
SPOTIFY_AUTH_DESTINATION="$CURDIR/../android/spotify-auth/spotify-auth.aar"

get_android_modules() {
    echo -e "\033[33m   * get android modules\033[39m"
    
    echo -n "- Downloading spotify-app-remote v$SPOTIFY_APP_REMOTE_VERSION > $SPOTIFY_APP_REMOTE_DESTINATION"
    curl -sL $SPOTIFY_APP_REMOTE_RELEASE_URL > $SPOTIFY_APP_REMOTE_DESTINATION \
        && echo " ✅ " \
        || echo " ❌ Fail - Please check manually"
    
    echo -n "- Downloading spotify-auth v$SPOTIFY_AUTH_VERSION > $SPOTIFY_AUTH_DESTINATION"
    curl -sL $SPOTIFY_AUTH_RELEASE_URL > $SPOTIFY_AUTH_DESTINATION \
        && echo " ✅ " \
        || echo " ❌ Fail - Please check manually"
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

get_android_modules
check_latest_release
