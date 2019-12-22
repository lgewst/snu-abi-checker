#!/bin/bash

cd /var/www/html

active="/var/www/html/active"
inactive="/var/www/html/inactive"
if [ -e "$inactive" ]; then
	echo "abi-checker has been disabled"
	exit 1
fi

cd ~

#make sure you have two build file
#make sure you have old.xml and new.xml
#make sure you have webos.json file

#19.12.04 add report path variable
reportPath="/var/www/html/"

oldVersion=$(ls -td ./src/webos/*/ | head -1)
oldVersion="$(basename ${oldVersion})"

echo "get webos new release"
abi-monitor -get webos.json

newVersion=$(ls -td ./src/webos/*/ | head -1)
newVersion="$(basename ${newVersion})"

if [ "$oldVersion" != "$newVersion" ]; then
    echo "new version found!"
    echo "remove old build file"
#sudo rm -rf "$(ls -trd ./installed/webos/*/ | head -1)"
    
    echo "extract new release"
    dir="./src/webos/$newVersion"
    mkdir ./installed/webos/$newVersion
    for entry in "$dir"/*
    do
        echo "$entry"
        tar zxvf "$entry" -C ./installed/webos/$newVersion
    done

    echo "build new release starting..."
    buildfileName=$(ls -d ./installed/webos/$newVersion/*/|head -n 1)
    echo "$buildfileName"
    cp ./build_scripts/webos.sh $buildfileName
    cd $buildfileName
    ./webos.sh
	
	cd ~
    echo "swap old and new xml"
    cp OLD.xml tmp.xml
    rm OLD.xml
    mv NEW.xml OLD.xml
    mv tmp.xml NEW.xml

    echo "get the new version's path"
    newName=$(ls ./installed/webos/${newVersion}/ | head -1)
    newPath="./installed/webos/$newVersion/$newName/BUILD/sysroots-components/raspberrypi4/"

    echo "change version and directories of new xml"

    #header files that are checked:
    wayland=$newPath"wayland"
    pixman=$newPath"pixman"
    icu=$newPath"icu"
    libxkbcommon=$newPath"libxkbcommon"
    libexif=$newPath"libexif"
    dbus=$newPath"dbus"
    libcap=$newPath"libcap"
    elfutils=$newPath"elfutils"
    nspr=$newPath"nspr"
    curl=$newPath"curl"
    waylandEx=$newPath"webos-wayland-extensions"
    
    sed -i "2s%.*%$newVersion%g" NEW.xml
    sed -i "6s%.*%$wayland%g" NEW.xml
    sed -i "7s%.*%$pixman%g" NEW.xml
    sed -i "8s%.*%$icu%g" NEW.xml
    sed -i "9s%.*%$libxkbcommon%g" NEW.xml
    sed -i "10s%.*%$libexif%g" NEW.xml
    sed -i "11s%.*%$dbus%g" NEW.xml
    sed -i "12s%.*%$libcap%g" NEW.xml
    sed -i "13s%.*%$elfutils%g" NEW.xml
    sed -i "14s%.*%$nspr%g" NEW.xml
    sed -i "15s%.*%$curl%g" NEW.xml
    sed -i "16s%.*%$waylandEx%g" NEW.xml
    sed -i "20s%.*%$newPath%g" NEW.xml
fi

echo "run abi-compliance checker"
abi-compliance-checker -gcc-options -Werror -lib webos -old OLD.xml -new NEW.xml
if [ "$?" = 1 ] 
then
    echo "success"
    echo "move reports to root html directories"
    
    tmp=$(ls -td ./compat_reports/webos/*/ | head -n 1)
    tmpname="$(basename $tmp)"
    reportName=$tmpname"_report.html"
    cd /var/www/html

    if [ ! -f "$reportName" ]; then
        cd ~
		sudo cp $tmp"compat_report.html" $reportPath$reportName
    fi

    #Create JIRA issue
    cd ~
	sudo ./jiraissue/createIssue.sh $reportPath $reportName
    exit 2
else
    echo "fail"
    echo "sending mail..."
    echo "failed to run abi checker" | mail -s "ABI failure report" "herojun9696@gmail.com"
fi


