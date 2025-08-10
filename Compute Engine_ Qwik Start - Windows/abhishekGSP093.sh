#!/bin/bash

# Define color variables
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

# Define text formatting variables
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear


echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}         INITIATING EXECUTION...        ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}  Welcome to Dr. Abhishek's Cloud Lab  ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}Please like, share and subscribe to:${RESET_FORMAT}"
echo "${MAGENTA_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo

# Instruction to check authentication
echo "${CYAN_TEXT}${BOLD_TEXT}Step 1:${RESET_FORMAT} ${WHITE_TEXT}Checking the authenticated accounts in gcloud.${RESET_FORMAT}"
gcloud auth list

# Instruction to set the zone
echo "${CYAN_TEXT}${BOLD_TEXT}Step 2:${RESET_FORMAT} ${WHITE_TEXT}Fetching the default compute zone for the project.${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# Instruction to create the instance
echo "${CYAN_TEXT}${BOLD_TEXT}Step 3:${RESET_FORMAT} ${WHITE_TEXT}Creating a new Compute Engine instance named 'drabhishek'.${RESET_FORMAT}"
gcloud compute instances create cloud-instance --project=$DEVSHELL_PROJECT_ID --zone $ZONE --machine-type=e2-medium --create-disk=auto-delete=yes,boot=yes,device-name=cloud-instance,image=projects/windows-cloud/global/images/windows-server-2022-dc-v20230913,mode=rw,size=50,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced 

# Instruction to wait for the instance to initialize
echo "${YELLOW_TEXT}${BOLD_TEXT}Please wait for 30 seconds while the instance initializes...${RESET_FORMAT}"
sleep 30

# Instruction to get serial port output
echo "${CYAN_TEXT}${BOLD_TEXT}Step 4:${RESET_FORMAT} ${WHITE_TEXT}Fetching the serial port output of the instance.${RESET_FORMAT}"
gcloud compute instances get-serial-port-output cloud-instance --zone=$ZONE

# Instruction to reset the Windows password
echo "${CYAN_TEXT}${BOLD_TEXT}Step 5:${RESET_FORMAT} ${WHITE_TEXT}Resetting the Windows password for the 'admin' user.${RESET_FORMAT}"
gcloud compute reset-windows-password cloud-instance --zone $ZONE --user admin --quiet


echo
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY!              ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}Thank you for completing this lab!${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}For more cloud tutorials, subscribe to:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}Dr. Abhishek's YouTube Channel${RESET_FORMAT}"
echo "${MAGENTA_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo
