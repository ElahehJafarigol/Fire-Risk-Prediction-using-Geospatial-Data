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
    echo "https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023074100624_O24093_03_T09845_02_003_02_V002/GEDI02_A_2023074100624_O24093_03_T09845_02_003_02_V002.h5"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 5 --netrc-file "$netrc" https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023074100624_O24093_03_T09845_02_003_02_V002/GEDI02_A_2023074100624_O24093_03_T09845_02_003_02_V002.h5 -w '\n%{http_code}' | tail  -1`
    if [ "$approved" -ne "200" ] && [ "$approved" -ne "301" ] && [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w '\n%{http_code}' https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023074100624_O24093_03_T09845_02_003_02_V002/GEDI02_A_2023074100624_O24093_03_T09845_02_003_02_V002.h5 | tail -1)
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
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023074100624_O24093_03_T09845_02_003_02_V002/GEDI02_A_2023074100624_O24093_03_T09845_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023073030844_O24073_02_T10896_02_003_02_V002/GEDI02_A_2023073030844_O24073_02_T10896_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023072035526_O24058_02_T07224_02_003_02_V002/GEDI02_A_2023072035526_O24058_02_T07224_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023069044227_O24012_02_T07897_02_003_02_V002/GEDI02_A_2023069044227_O24012_02_T07897_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023066131344_O23971_03_T08422_02_003_02_V002/GEDI02_A_2023066131344_O23971_03_T08422_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023065061634_O23951_02_T09167_02_003_02_V002/GEDI02_A_2023065061634_O23951_02_T09167_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023062144913_O23910_03_T03694_02_003_02_V002/GEDI02_A_2023062144913_O23910_03_T03694_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023058162406_O23849_03_T06387_02_003_02_V002/GEDI02_A_2023058162406_O23849_03_T06387_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023054175821_O23788_03_T02118_02_003_02_V002/GEDI02_A_2023054175821_O23788_03_T02118_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023053110035_O23768_02_T08555_02_003_02_V002/GEDI02_A_2023053110035_O23768_02_T08555_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023046210938_O23666_03_T07045_02_003_02_V002/GEDI02_A_2023046210938_O23666_03_T07045_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023045141251_O23646_02_T09213_02_003_02_V002/GEDI02_A_2023045141251_O23646_02_T09213_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023042224612_O23605_03_T00894_02_003_02_V002/GEDI02_A_2023042224612_O23605_03_T00894_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023039002204_O23544_03_T10549_02_003_02_V002/GEDI02_A_2023039002204_O23544_03_T10549_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023037172449_O23524_02_T01486_02_003_02_V002/GEDI02_A_2023037172449_O23524_02_T01486_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023036011021_O23498_03_T11222_02_003_02_V002/GEDI02_A_2023036011021_O23498_03_T11222_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023035015721_O23483_03_T07550_02_003_02_V002/GEDI02_A_2023035015721_O23483_03_T07550_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023033190028_O23463_02_T01027_02_003_02_V002/GEDI02_A_2023033190028_O23463_02_T01027_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023032024707_O23437_03_T03342_02_003_02_V002/GEDI02_A_2023032024707_O23437_03_T03342_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023030195038_O23417_02_T06933_02_003_02_V002/GEDI02_A_2023030195038_O23417_02_T06933_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023029203816_O23402_02_T08800_02_003_02_V002/GEDI02_A_2023029203816_O23402_02_T08800_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023028042446_O23376_03_T06999_02_003_02_V002/GEDI02_A_2023028042446_O23376_03_T06999_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023024060158_O23315_03_T03541_02_003_02_V002/GEDI02_A_2023024060158_O23315_03_T03541_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023022230511_O23295_02_T10131_02_003_02_V002/GEDI02_A_2023022230511_O23295_02_T10131_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023020073829_O23254_03_T03082_02_003_02_V002/GEDI02_A_2023020073829_O23254_03_T03082_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023019004128_O23234_02_T02557_02_003_02_V002/GEDI02_A_2023019004128_O23234_02_T02557_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023016091535_O23193_03_T11161_02_003_02_V002/GEDI02_A_2023016091535_O23193_03_T11161_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023015021902_O23173_02_T10483_02_003_02_V002/GEDI02_A_2023015021902_O23173_02_T10483_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023013100528_O23147_03_T04260_02_003_02_V002/GEDI02_A_2023013100528_O23147_03_T04260_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023012105258_O23132_03_T04857_02_003_02_V002/GEDI02_A_2023012105258_O23132_03_T04857_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023011035617_O23112_02_T04179_02_003_02_V002/GEDI02_A_2023011035617_O23112_02_T04179_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023009114231_O23086_03_T02378_02_003_02_V002/GEDI02_A_2023009114231_O23086_03_T02378_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023007053305_O23051_02_T10835_02_003_02_V002/GEDI02_A_2023007053305_O23051_02_T10835_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023005131909_O23025_03_T08881_02_003_02_V002/GEDI02_A_2023005131909_O23025_03_T08881_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023004062212_O23005_02_T05510_02_003_02_V002/GEDI02_A_2023004062212_O23005_02_T05510_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023003070929_O22990_02_T07530_02_003_02_V002/GEDI02_A_2023003070929_O22990_02_T07530_02_003_02_V002.h5
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/GEDI02_A.002/GEDI02_A_2023001145522_O22964_03_T09998_02_003_02_V002/GEDI02_A_2023001145522_O22964_03_T09998_02_003_02_V002.h5
EDSCEOF