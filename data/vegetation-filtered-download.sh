#!/bin/bash

GREP_OPTIONS=''

cookiejar=$(mktemp cookies.XXXXXXXXXX)
netrc=$(mktemp netrc.XXXXXXXXXX)
chmod 0600 "$cookiejar" "$netrc"
function finish {
  rm -rf "$cookiejar" "$netrc"
}

trap finish EXIT
WGETRC="$wgetrc"

prompt_credentials() {
    echo "Enter your Earthdata Login or other provider supplied credentials"
    read -p "Username (elaheh.jafarigol): " username
    username=${username:-elaheh.jafarigol}
    read -s -p "Password: " password
    echo "machine urs.earthdata.nasa.gov login $username password $password" >> $netrc
    echo
}

exit_with_error() {
    echo
    echo "Unable to Retrieve Data"
    echo
    echo $1
    echo
    echo "https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2022353.h08v05.061.2023006045320/MOD13Q1.A2022353.h08v05.061.2023006045320.hdf"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 5 --netrc-file "$netrc" https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2022353.h08v05.061.2023006045320/MOD13Q1.A2022353.h08v05.061.2023006045320.hdf -w '\n%{http_code}' | tail  -1`
    if [ "$approved" -ne "200" ] && [ "$approved" -ne "301" ] && [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w '\n%{http_code}' https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2022353.h08v05.061.2023006045320/MOD13Q1.A2022353.h08v05.061.2023006045320.hdf | tail -1)
    if [[ "$status" -ne "200" && "$status" -ne "304" ]]; then
        # URS authentication is required. Now further check if the application/remote service is approved.
        detect_app_approval
    fi
}

setup_auth_wget() {
    # The safest way to auth via curl is netrc. Note: there's no checking or feedback
    # if login is unsuccessful
    touch ~/.netrc
    chmod 0600 ~/.netrc
    credentials=$(grep 'machine urs.earthdata.nasa.gov' ~/.netrc)
    if [ -z "$credentials" ]; then
        cat "$netrc" >> ~/.netrc
    fi
}

fetch_urls() {
  if command -v curl >/dev/null 2>&1; then
      setup_auth_curl
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        curl -f -b "$cookiejar" -c "$cookiejar" -L --netrc-file "$netrc" -g -o $stripped_query_params -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  elif command -v wget >/dev/null 2>&1; then
      # We can't use wget to poke provider server to get info whether or not URS was integrated without download at least one of the files.
      echo
      echo "WARNING: Can't find curl, use wget instead."
      echo "WARNING: Script may not correctly identify Earthdata Login integrations."
      echo
      setup_auth_wget
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        wget --load-cookies "$cookiejar" --save-cookies "$cookiejar" --output-document $stripped_query_params --keep-session-cookies -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  else
      exit_with_error "Error: Could not find a command-line downloader.  Please install curl or wget"
  fi
}

fetch_urls <<'EDSCEOF'
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2022353.h08v05.061.2023006045320/MOD13Q1.A2022353.h08v05.061.2023006045320.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023001.h08v05.061.2023019192019/MOD13Q1.A2023001.h08v05.061.2023019192019.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023017.h08v05.061.2023034172632/MOD13Q1.A2023017.h08v05.061.2023034172632.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023033.h08v05.061.2023054055415/MOD13Q1.A2023033.h08v05.061.2023054055415.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023049.h08v05.061.2023070134303/MOD13Q1.A2023049.h08v05.061.2023070134303.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023065.h08v05.061.2023082002508/MOD13Q1.A2023065.h08v05.061.2023082002508.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023081.h08v05.061.2023100010342/MOD13Q1.A2023081.h08v05.061.2023100010342.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023097.h08v05.061.2023115121104/MOD13Q1.A2023097.h08v05.061.2023115121104.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023113.h08v05.061.2023130000716/MOD13Q1.A2023113.h08v05.061.2023130000716.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023129.h08v05.061.2023146132410/MOD13Q1.A2023129.h08v05.061.2023146132410.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023145.h08v05.061.2023164011025/MOD13Q1.A2023145.h08v05.061.2023164011025.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023161.h08v05.061.2023177233340/MOD13Q1.A2023161.h08v05.061.2023177233340.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023177.h08v05.061.2023201060804/MOD13Q1.A2023177.h08v05.061.2023201060804.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023193.h08v05.061.2023215110410/MOD13Q1.A2023193.h08v05.061.2023215110410.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023209.h08v05.061.2023226001045/MOD13Q1.A2023209.h08v05.061.2023226001045.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023225.h08v05.061.2023242000310/MOD13Q1.A2023225.h08v05.061.2023242000310.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023241.h08v05.061.2023258002222/MOD13Q1.A2023241.h08v05.061.2023258002222.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023257.h08v05.061.2023274001853/MOD13Q1.A2023257.h08v05.061.2023274001853.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023273.h08v05.061.2023290141728/MOD13Q1.A2023273.h08v05.061.2023290141728.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023289.h08v05.061.2023306000757/MOD13Q1.A2023289.h08v05.061.2023306000757.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023305.h08v05.061.2023322213248/MOD13Q1.A2023305.h08v05.061.2023322213248.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023321.h08v05.061.2023340010650/MOD13Q1.A2023321.h08v05.061.2023340010650.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023337.h08v05.061.2023354005807/MOD13Q1.A2023337.h08v05.061.2023354005807.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13Q1.061/MOD13Q1.A2023353.h08v05.061.2024005150850/MOD13Q1.A2023353.h08v05.061.2024005150850.hdf
EDSCEOF