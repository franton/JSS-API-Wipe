#!/bin/bash

# Script to wipe a JSS via API
# richard at richard - purves dot com
# Written while listening to "The Devil's Trill Sonata" by Giuseppe Tartini on repeat.

# v1.0 : 14-06-2017 - Initial version
# v1.1 : 21-07-2017 - Swapped computer groups and extension attributes around for reliability.

# Deliberately leaves accounts alone. So you can get back in ;)

# These are the categories we're going to process
declare -a jssitem
jssitem[0]="sites"							# Backend configuration
jssitem[1]="categories"
jssitem[2]="ldapservers"
jssitem[3]="buildings"
jssitem[4]="departments"
jssitem[5]="directorybindings"
jssitem[6]="removablemacaddresses"
jssitem[7]="netbootservers"
jssitem[8]="distributionpoints"
jssitem[9]="softwareupdateservers"
jssitem[10]="networksegments"
jssitem[11]="healthcarelistener"
jssitem[12]="ibeacons"
jssitem[13]="infrastructuremanager"
jssitem[14]="peripherals"
jssitem[15]="peripheraltypes"
jssitem[16]="smtpserver"
jssitem[17]="vppaccounts"
jssitem[18]="vppassignments"
jssitem[19]="vppinvitations"
jssitem[20]="webhooks"
jssitem[21]="diskencryptionconfigurations"
jssitem[22]="ebooks"
jssitem[23]="computergroups" 	# Computer configuration
jssitem[24]="dockitems"
jssitem[25]="printers"
jssitem[26]="licensedsoftware"
jssitem[27]="scripts"
jssitem[28]="computerextensionattributes"
jssitem[29]="restrictedsoftware"
jssitem[30]="osxconfigurationprofiles"
jssitem[31]="macapplications"
jssitem[32]="managedpreferenceprofiles"
jssitem[33]="packages"
jssitem[34]="policies"
jssitem[35]="advancedcomputersearches"
jssitem[36]="patches"
jssitem[37]="mobiledevicegroups"			# Mobile configuration
jssitem[38]="mobiledeviceapplications"
jssitem[39]="mobiledeviceconfigurationprofiles"
jssitem[40]="mobiledeviceenrollmentprofiles"
jssitem[41]="mobiledeviceextensionattributes"
jssitem[42]="mobiledeviceprovisioningprofiles"
jssitem[43]="classes"
jssitem[44]="advancedmobiledevicesearches"
jssitem[45]="userextensionattributes"		# User configuration
jssitem[46]="usergroups"
jssitem[47]="users"
jssitem[48]="advancedusersearches"

# Setting IFS Env to only use new lines as field seperator 
OIFS=$IFS
IFS=$'\n'

echo -e "\n"
read -p "Enter the JSS server address (https://www.example.com:8443) : " jssaddress
read -p "Enter the JSS server api username : " jssapiuser
read -p "Enter the JSS api user password : " -s jssapipwd

# Ask which instance we need to process, check if it exists and go from there
echo -e "\n"
echo "Enter the JSS instance name to wipe"
read -p "(Or enter for a non-context JSS) : " jssinstance

# Check for the skip
if [[ $jssinstance != "" ]];
then
	jssinstance="/$instance/"
fi

# THIS IS YOUR LAST CHANCE TO PUSH THE CANCELLATION BUTTON

echo -e "\n"
echo "Are you utterly sure you want to do this?"
read -p "(Default is NO. Type YES to go ahead) : " arewesure

# Check for the skip
if [[ $arewesure != "YES" ]];
then
	echo "Ok, quitting."
	exit 0
fi

# OK DO IT

for (( loop=0; loop<${#jssitem[@]}; loop++ ))
do
	# Set our result incremental variable to 1
	export resultInt=1

	# Grab all existing ID's for the current category we're processing
	echo -e "\n\nProcessing ID list for ${jssitem[$loop]}\n"
	curl -k --user "$jssapiuser:$jssapipwd" $jssaddress$jssinstance/JSSResource/${jssitem[$loop]} | xmllint --format - > /tmp/unprocessedid
#	curl -s -k --user "$jssapiuser:$jssapipwd" $jssaddress$jssinstance/JSSResource/${jssitem[$loop]} | xmllint --format - > /tmp/unprocessedid

	# Check if any ids have been captured. Skip if none present.
	check=$( echo /tmp/unprocessedid | grep "<size>0</size>" | wc -l | awk '{ print $1 }' )

	if [ "$check" = "0" ];
	then
		# What are we deleting?
		echo -e "\nDeleting ${jssitem[$loop]}"
	
		# Process all the item id numbers
		cat /tmp/unprocessedid | awk -F'<id>|</id>' '/<id>/ {print $2}' > /tmp/processedid

		# Delete all the item id numbers
		totalFetchedIDs=$( cat /tmp/processedid | wc -l | sed -e 's/^[ \t]*//' )
	
		for apiID in $(cat /tmp/processedid)
		do
			echo "Deleting ID number $apiID ( $resultInt out of $totalFetchedIDs )"
			curl -k --user "$jssapiuser:$jssapipwd" -H "Content-Type: application/xml" -X DELETE "$jssaddress$jssinstance/JSSResource/${jssitem[$loop]}/id/$apiID"
#			curl -s -k --user "$jssapiuser:$jssapipwd" -H "Content-Type: application/xml" -X DELETE "$jssaddress$jssinstance/JSSResource/${jssitem[$loop]}/id/$apiID"
			resultInt=$(($resultInt + 1))
		done	
	else
		echo -e "\nCategory ${jssitem[$loop]} is empty. Skipping."
	fi
done

# Setting IFS back to default 
IFS=$OIFS

# All done!
echo "Wipe operation completed."
exit 0