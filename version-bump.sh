# RUN ONLY ON dev/0.103.2xx
# ========================
BRANCH_NAME=$(git branch | awk '$1 ~/^\*/' | cut -c 3-)
if [[ $BRANCH_NAME == "dev/0.103.2xx" ]]; then
    CURR_VER=$(git describe --tags --abbrev=0 --match="v[0-9]*" | cut -c 2-)
    NEW_VER=$(echo "$CURR_VER" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')


    FILES_TO_UPDATE="CMakeLists.txt, Jenkinsfile, configure.ac, m4/reorganization/version.m4, win32/ClamAV-Installer.iss, win32/clamav-config.h, win32/clamav-version.h, win32/res/common.rc, win32/update-win32.pl"

    FIELD_SEPARATOR=$IFS
    IFS=", "
    for file in $FILES_TO_UPDATE; do
        sed -i "s/${CURR_VER}/${NEW_VER}/g" "$file"
        git add "$file"
    done
    IFS=$FIELD_SEPARATOR

    git commit -m "Version bump to: v${NEW_VER}"
    git tag "v${NEW_VER}"
    git push --atomic origin $BRANCH_NAME "v${NEW_VER}"
fi
