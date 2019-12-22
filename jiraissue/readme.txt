-Creating JIRA issue-
    - This shell script makes JIRA issues when the ABICC report is created.
    - It is executed by ../checker.sh

* Requirement
    1. jq
        - This is used for parsing JSON file.
        - How to install: (sudo) apt-get install jq
    2. xmllint
        - This is used for parsing HTML file(report).
    3. curl

* Input
    1. ./config.json
        - This includes JIRA login email, URI, project key, API token.

    2. abicc report(/var/www/html/*_to_*_report.html)

* Output
    1. ./issue.json
        - You can check properties of JIRA issue.
    2. ./xmllint.error
        - You can check error of xmllint operation.
