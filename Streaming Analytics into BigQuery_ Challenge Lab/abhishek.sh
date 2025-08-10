#!/bin/bash

# Bright Foreground Colors
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

# Displaying start message
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                  Welcome to Dr Abhishek Cloud Tutorial                ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
read -r -p "${YELLOW_TEXT}${BOLD_TEXT}Enter REGION: ${RESET_FORMAT}" REGION
export REGION=$REGION

echo
read -r -p "${YELLOW_TEXT}${BOLD_TEXT}Enter DATASET name: ${RESET_FORMAT}" DATASET
export DATASET=$DATASET

echo
read -r -p "${YELLOW_TEXT}${BOLD_TEXT}Enter TABLE name: ${RESET_FORMAT}" TABLE
export TABLE=$TABLE

echo
read -r -p "${YELLOW_TEXT}${BOLD_TEXT}Enter TOPIC name: ${RESET_FORMAT}" TOPIC
export TOPIC=$TOPIC

echo
read -r -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the JOB name: ${RESET_FORMAT}" JOB
export JOB=$JOB

export PROJECT_ID=$(gcloud config get-value project)

gsutil mb gs://$PROJECT_ID

bq mk $DATASET

bq mk --table \
$PROJECT_ID:$DATASET.$TABLE \
data:string

gcloud pubsub topics create $TOPIC

gcloud pubsub subscriptions create $TOPIC-sub --topic=$TOPIC

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Starting Dataflow Flex Template Job ========================== ${RESET_FORMAT}"
echo

gcloud dataflow flex-template run $JOB --region $REGION \
--template-file-gcs-location gs://dataflow-templates-$REGION/latest/flex/PubSub_to_BigQuery_Flex \
--temp-location gs://$PROJECT_ID/temp/ \
--parameters outputTableSpec=$PROJECT_ID:$DATASET.$TABLE,\
inputTopic=projects/$PROJECT_ID/topics/$TOPIC,\
outputDeadletterTable=$PROJECT_ID:$DATASET.$TABLE,\
javascriptTextTransformReloadIntervalMinutes=0,\
useStorageWriteApi=false,\
useStorageWriteApiAtLeastOnce=false,\
numStorageWriteApiStreams=0

#!/bin/bash
echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Monitoring and Interacting with Dataflow Job ========================== ${RESET_FORMAT}"
echo

while true; do
    STATUS=$(gcloud dataflow jobs list --region="$REGION" --format='value(STATE)' | grep Running)
    
    if [ "$STATUS" == "Running" ]; then
        echo "The Dataflow job is running successfully"

        sleep 20
        gcloud pubsub topics publish $TOPIC --message='{"data": "73.4 F"}'

        bq query --nouse_legacy_sql "SELECT * FROM \`$DEVSHELL_PROJECT_ID.$DATASET.$TABLE\`"
        break
    else
        sleep 30
        echo "The Dataflow job is not running please wait..."
    fi
done

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Starting Another Dataflow Job ========================== ${RESET_FORMAT}"
echo
gcloud dataflow jobs run $JOB-abhishekcloud --gcs-location gs://dataflow-templates-$REGION/latest/PubSub_to_BigQuery --region=$REGION --project=$PROJECT_ID --staging-location gs://$PROJECT_ID/temp --parameters inputTopic=projects/$PROJECT_ID/topics/$TOPIC,outputTableSpec=$PROJECT_ID:$DATASET.$TABLE

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Monitoring and Interacting with Second Dataflow Job ========================== ${RESET_FORMAT}"
echo

while true; do
    STATUS=$(gcloud dataflow jobs list --region=$REGION --project=$PROJECT_ID --filter="name:$JOB-abhishekcloud AND state:Running" --format="value(state)")
    
    if [ "$STATUS" == "Running" ]; then
        echo "The Dataflow job is running successfully"

        sleep 20
        gcloud pubsub topics publish $TOPIC --message='{"data": "73.4 F"}'

        bq query --nouse_legacy_sql "SELECT * FROM \`$PROJECT_ID.$DATASET.$TABLE\`"
        break
    else
        sleep 30
        echo "The Dataflow job is not running please wait..."
    fi
done

echo

echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              Lab Completed Successfully!               ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${RED_TEXT}${BOLD_TEXT}Subscribe to Dr. Abhishek Cloud Tutorials:${RESET_FORMAT} ${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo
