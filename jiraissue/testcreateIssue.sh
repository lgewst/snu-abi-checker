#DT = Data Tpes, Sym = Symbols
#bin, Bin = Binary, src, Src = Source

#$1 = reportPath, $2 = reportName

#reportPath=$1
#reportName=$2
#newReportName=$1$2
newReportName=1.0_to_2.0_report.html
reportName=1.0_to_2.0_report.html
projectUri=$(cat ~/jiraissue/config.json | jq -r .jirauri)
projectKey=$(cat ~/jiraissue/config.json | jq -r .projectkey)
jiraUsername=$(cat ~/jiraissue/config.json | jq -r .email)
jiraApiToken=$(cat ~/jiraissue/config.json | jq -r .apitoken)

#Check report
if [ -f $newReportName ]; then
    echo "report exist"
else
    echo "The path is not valid"
    exit 1
fi

#Make description with report html
binCompatibilityPath="html/body/div[2]/table[2]/tr[4]/td"
binProblemPath="html/body/div[2]/table[3]"

binCompatibility=$(xmllint --noout --html --xpath $binCompatibilityPath'/text()' $newReportName 2>xmllint.error)
binRemovedSym=$(xmllint --html --xpath $binProblemPath'/tr[3]/td/a/text()' $newReportName 2>xmllint.error)
binProblemDTHigh=$(xmllint --html --xpath $binProblemPath'/tr[4]/td/a/text()' $newReportName 2>xmllint.error)
binProblemDTMedium=$(xmllint --html --xpath $binProblemPath'/tr[5]/td/a/text()' $newReportName 2>xmllint.error)
binProblemDTLow=$(xmllint --html --xpath $binProblemPath'/tr[6]/td/a/text()' $newReportName 2>xmllint.error)
binProblemSymHigh=$(xmllint --html --xpath $binProblemPath'/tr[7]/td/a/text()' $newReportName 2>xmllint.error)
binProblemSymMedium=$(xmllint --html --xpath $binProblemPath'/tr[8]/td/a/text()' $newReportName 2>xmllint.error)
binProblemSymLow=$(xmllint --html --xpath $binProblemPath'/tr[9]/td/a/text()' $newReportName 2>xmllint.error)

srcCompatibilityPath="html/body/div[3]/table[2]/tr[4]/td"
srcProblemPath="html/body/div[3]/table[3]"

srcCompatibility=$(xmllint --html --xpath $srcCompatibilityPath'/text()' $newReportName 2>xmllint.error)
srcRemovedSym=$(xmllint --html --xpath $srcProblemPath'/tr[3]/td/a/text()' $newReportName 2>xmllint.error)
srcProblemDTHigh=$(xmllint --html --xpath $srcProblemPath'/tr[4]/td/a/text()' $newReportName 2>xmllint.error)
srcProblemDTMedium=$(xmllint --html --xpath $srcProblemPath'/tr[5]/td/a/text()' $newReportName 2>xmllint.error)
srcProblemDTLow=$(xmllint --html --xpath $srcProblemPath'/tr[6]/td/a/text()' $newReportName 2>xmllint.error)
srcProblemSymHigh=$(xmllint --html --xpath $srcProblemPath'/tr[7]/td/a/text()' $newReportName 2>xmllint.error)
srcProblemSymMedium=$(xmllint --html --xpath $srcProblemPath'/tr[8]/td/a/text()' $newReportName 2>xmllint.error)
srcProblemSymLow=$(xmllint --html --xpath $srcProblemPath'/tr[9]/td/a/text()' $newReportName 2>xmllint.error)

#if value is blank, put Zero
if [ "$binRemovedSym" == "" ]; then
	binRemovedSym=0
fi
if [ "$binProblemDTHigh" == "" ]; then
	binProblemDTHigh=0
fi
if [ "$binProblemDTMedium" == "" ]; then
	binProblemDTMedium=0
fi
if [ "$binProblemDTLow" == "" ]; then
	binProblemDTLow=0
fi
if [ "$binProblemSymHigh" == "" ]; then
	binProblemSymHigh=0
fi
if [ "$binProblemSymMedium" == "" ]; then
	binProblemSymMedium=0
fi
if [ "$binProblemSymLow" == "" ]; then
	binProblemSymLow=0
fi
if [ "$srcRemovedSym" == "" ]; then
	srcRemovedSym=0
fi
if [ "$srcProblemDTHigh" == "" ]; then
	srcProblemDTHigh=0
fi
if [ "$srcProblemDTMedium" == "" ]; then
	srcProblemDTMedium=0
fi
if [ "$srcProblemDTLow" == "" ]; then
	srcProblemDTLow=0
fi
if [ "$srcProblemSymHigh" == "" ]; then
	srcProblemSymHigh=0
fi
if [ "$srcProblemSymMedium" == "" ]; then
	srcProblemSymMedium=0
fi
if [ "$srcProblemSymLow" == "" ]; then
	srcProblemSymLow=0
fi

binSummary="\\r\\n<Binary>\\r\\n\\r\\n- Compatibility: $binCompatibility\\r\\n\\r\\nBinary Problem Summary(fraction)\\r\\n- Removed Symbols: $binRemovedSym\\r\\n- Problems with Data Types\\r\\nHigh: $binProblemDTHigh Medium: $binProblemDTMedium Low: $binProblemDTLow\\r\\n- Problems with Symbols\\r\\nHigh: $binProblemSymHigh Medium: $binProblemSymMedium Low: $binProblemDTLow\\r\\n"

srcSummary="\\r\\n<Source>\\r\\n\\r\\n- Compatibility: $srcCompatibility\\r\\n\\r\\nSource Problem Summary(fraction)\\r\\n- Removed Symbols: $srcRemovedSym\\r\\n- Problems with Data Types\\r\\nHigh: $srcProblemDTHigh Medium: $srcProblemDTMedium Low: $srcProblemDTLow\\r\\n- Problems with Symbols\\r\\nHigh: $srcProblemSymHigh Medium: $srcProblemSymMedium Low: $srcProblemDTLow\\r\\n"

description=$binSummary$srcSummary

issueFields="{\"fields\": {\"project\": {\"key\": \"$projectKey\"}, \"summary\": \"$reportName has creadted.\", \"description\": \"$description\", \"issuetype\": {\"name\": \"Bug\"}, \"priority\": {\"name\": \"High\"}}}"
#\"timetracking\": {\"originalEstimate\": \"0m\", \"remainingEstimate\": \"1w\"}

curlData=$(echo $issueFields > issue.json)

#Create an issue
curl -D- -u $jiraUsername":"$jiraApiToken -X POST --data @issue.json -H """Content-Type: application/json""" https://$projectUri"/rest/api/2/issue/"
