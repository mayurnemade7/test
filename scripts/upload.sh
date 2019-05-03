APKNAME=""
HOCKEY_APP_ID=""
HOCKEY_APP_TOKEN=""

OUTPUT_FILE_NAME="./release_notes/V2 - LT - MyLendingTree - Android-b"	

FILENAME="./app/build.gradle"
#FILENAME="/home/v2team/ast2/princess-messenger-android-app/app/build.gradle"

#FILENAME=$1
LABEL_ID=""
count=0

while read LINE; do
let count++
if [ "$LINE" = "DEV {" ] && [ "$TRAVIS_BRANCH"  = "DEV" ]; then
	let count++
	variable=`ps -ef | grep "port 10 -" | grep -v "grep port 10 -" | awk NR==$count $FILENAME`
	let count--
    	IN=$variable
	arr=(`echo $IN | tr ' ' ' '`)
	
	
fi
if [ "$LINE" = "QA {" ] && [ "$TRAVIS_BRANCH" = "QA" ]; then
	let count++
	variable=`ps -ef | grep "port 10 -" | grep -v "grep port 10 -" | awk NR==$count $FILENAME`
	let count--
    	IN=$variable
	arr=(`echo $IN | tr ' ' ' '`)	
	
fi


done < $FILENAME
LABEL_ID=${arr[1]}
echo "$LABEL_ID"


# Condition which defines the Build Env used and based on that selection of the Hockey App Id and Hockey App token
if ([ "$TRAVIS_BRANCH"  = "develop" ]); then
    APP_BUILD_ENV=DEV;
    HOCKEY_APP_ID=$DEV_HOCKEY_APP_ID;
    HOCKEY_APP_TOKEN=$DEV_HOCKEY_APP_TOKEN;
    APKNAME=$DEV_APKNAME
    echo "DEV Scheme Selected.";
elif ([ "$TRAVIS_BRANCH" = "QA" ]); then
    APP_BUILD_ENV=QA;
    HOCKEY_APP_ID=$QA_HOCKEY_APP_ID;
    HOCKEY_APP_TOKEN=$QA_HOCKEY_APP_TOKEN;
    APKNAME=$QA_APKNAME
    echo "QA Scheme Selected.";

else
    echo "No deployment will be done."
    exit 0
fi

# RELEASE_DATE : To specify the relase date of the build
RELEASE_DATE='date '+%Y-%m-%d %H:%M:%S''

OUTPUT_FILE_NAME="$OUTPUT_FILE_NAME$LABEL_ID.txt"


# Condition to check the stories file is avaialable in release path
# If file is available then read the text from the file
if ([ -f "$OUTPUT_FILE_NAME" ]); then
    ALL_STORIES_WITH_ID=`cat "$OUTPUT_FILE_NAME"`
else
    echo "Error : File not found on path $OUTPUT_FILE_NAME .."
fi



#RELEASE_NOTES="$ALL_STORIES_WITH_ID <br> Travis Integration Build: $TRAVIS_BUILD_NUMBER"

#echo $RELEASE_NOTES

#Hockeyapp upload params
HOCKEY_APP_STATUS="2"
HOCKEY_APP_NOTIFY="0"
#HOCKEY_APP_NOTES="Build: 1.0.2 Uploaded: $RELEASE_DATE"
HOCKEY_APP_NOTES=$RELEASE_NOTES
HOCKEY_APP_NOTES_TYPE="0"

# upload via curl to Hockey app
if [ ! -z "$HOCKEY_APP_ID" ] && [ ! -z "$HOCKEY_APP_TOKEN" ]; then
echo ""
echo "***************************"
echo "* Uploading to Hockeyapp  *"
echo "***************************"
curl  \
-F "status=$HOCKEY_APP_STATUS" \
-F "notify=$HOCKEY_APP_NOTIFY" \
-F "notes=$HOCKEY_APP_NOTES" \
-F "notes_type=$HOCKEY_APP_NOTES_TYPE" \
-F "ipa=@$OUTPUTDIR/$APKNAME" \
-H "X-HockeyAppToken: $HOCKEY_APP_TOKEN" \
https://rink.hockeyapp.net/api/2/apps/$HOCKEY_APP_ID/app_versions/upload

echo "Upload finish"
else
	echo "Failed to Upload Build on Hockeyapp"
fi
