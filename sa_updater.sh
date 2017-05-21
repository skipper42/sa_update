#! /bin/bash


<<VERSION

DESCRIPTION:		This Script updates all provisioned servers.	
AUTHOR:				Akram Hamed (akram.hamed@rsa.com)
CURRENT VERSION:	0.9.2 Beta
CREATED:			Fri 30-OCT-2015
LAST REVISED:		Fri 02-NOV-2015

VERSION



<<LICENSE

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so.

The above copyright notice and this permission notice shallbe included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTI
CULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDE
RS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CON
TRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

LICENSE


<<VARIABLES

variables naming convention
===========================
decoder$i
range_dec
dec[i]
name_dec[i]
s_dec[i]
name_s_dec[i]
f_dec[i]
name_f_dec[i]
/tmp/U_dec

concentrator$i
range_conc
conc[i]
name_conc[i]
s_conc[i]
name_s_conc[i]
f_conc[i]
name_f_conc[i]
/tmp/U_conc

logdecoder$i
range_logdec
logdec[i]
name_logdec[i]
s_logdec[i]
name_s_logdec[i]
f_logdec[i]
name_f_logdec[i]
/tmp/U_logdec

broker$i
range_brok
brok[i]
name_brok[i]
s_brok[i]
name_s_brok[i]
f_brok[i]
name_f_brok[i]
/tmp/U_brok

malware_analysis$i
range_mal
mal[i]
name_mal[i]
s_mal[i]
name_s_mal[i]
f_mal[i]
name_f_mal[i]
/tmp/U_mal

archiver$i
range_arc
arc[i]
name_arc[i]
s_arc[i]
name_s_arc[i]
f_arc[i]
name_f_arc[i]
/tmp/U_arc

esa$i
range_esa
esa[i]
name_esa[i]
s_esa[i]
name_s_esa[i]
f_esa[i]
name_f_esa[i]
/tmp/U_esa

VARIABLES


clear


# Unsetting Global Variables, Just in case of sourcing
#=====================================================
unset s_dec;unset f_dec;unset s_logdec;unset f_logdec;unset s_conc;unset f_conc;unset s_brok;unset f_brok;unset s_mal;unset f_mal;unset s_esa;unset f_esa;unset s_arc;unset f_arc

# Making sure there is no left overs
#===================================
rm -f /tmp/U_esa /tmp/U_mal /tmp/U_dec /tmp/U_logdec /tmp/U_conc /tmp/U_arc /tmp/U_brok



sa_uuid=$(cd /var/lib/puppet/yaml/node; grep -Rw sa * | cut -d ':' -f1 | head -1)
malware_uuid=$(cd /var/lib/puppet/yaml/node; grep -w malware-analysis: * | cut -d ':' -f1 | head -1)



# BANNER
#==========

echo ""
echo ' ____    _      _   _           _       _'
echo '/ ___|  / \    | | | |_ __   __| | __ _| |_ ___ _ __'
echo '\___ \ / _ \   | | | |  _ \ / _  |/ _  | __/ _ \  __|'
echo ' ___) / ___ \  | |_| | |_) | (_| | (_| | ||  __/ |'
echo '|____/_/   \_\  \___/| .__/ \__,_|\__,_|\__\___|_|'
echo '                     |_|'
echo ""


# Only root can do stuff
#========================
# Make sure only root can run this script
echo "Just Checking you are ROOT"
sleep 1
if [ "$(id -u)" != "0" ]; then
	echo $'\n'
	echo "This script must be run as root, please login as root and try again" 1>&2
	echo $'\n'
	exit 1
fi
echo "Seems, you are actually ROOT !!"
echo ""
echo ""
#========================

echo '================ WARN !! ================='
echo ""
echo "Please note that you MUST FIRST make sure that all the Hosts are provisioned correctly in the GUI"
echo ""
read -r -p "Are you sure ALL hosts are provisioned in the GUI ? [y/N] " response
	case $response in
		[yY][eE][sS]|[yY])
			echo ""
			echo "Continuing at your choice"
			echo ""
			echo ""
			sleep 2
			;;
		*)
			echo ""
			echo "Exiting ...."
			echo ""
			sleep 2
			exit 1
			;;
	esac


#============================================================================
#============================  Calculating Phase  ===========================
#============================================================================

# check number and type of hosts
#================================

echo "Checking Number and Type of HOSTs"
echo "=================================="

# Decoder
#=========
cd /var/lib/puppet/yaml/node
range_dec=$(grep -w decoder: * | wc -l)
echo ""
echo number_of_decoders=$range_dec
for ((i=1; i<=range_dec; i++)); do

declare decoder$i=$(grep ipaddress: $(grep -w decoder: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8  | cut -c 2- | rev | cut -c 2- | rev)

declare name_decoder$i=$(grep hostname: $(grep -w decoder: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8)

dec[i]=$(eval echo \$decoder$i)
name_dec[i]=$(eval echo \$name_decoder$i)
echo "${name_dec[i]} ${dec[i]}"
done
echo ""
sleep 1

# Concentrator
#=============
cd /var/lib/puppet/yaml/node
range_conc=$(grep -w concentrator: * | wc -l)
echo ""
echo number_of_concentrators=$range_conc
for ((i=1; i<=range_conc; i++)); do

declare concentrator$i=$(grep ipaddress: $(grep -w concentrator: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8  | cut -c 2- | rev | cut -c 2- | rev)

declare name_concentrator$i=$(grep hostname: $(grep -w concentrator: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8)

conc[i]=$(eval echo \$concentrator$i)
name_conc[i]=$(eval echo \$name_concentrator$i)
echo "${name_conc[i]} ${conc[i]}"
done
echo ""
sleep 1

# LogDecoder
#============
cd /var/lib/puppet/yaml/node
range_logdec=$(grep -w logdecoder: * | wc -l)
echo ""
echo number_of_logdecoders=$range_logdec
for ((i=1; i<=range_logdec; i++)); do

declare logdecoder$i=$(grep ipaddress: $(grep -w logdecoder: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8  | cut -c 2- | rev | cut -c 2- | rev)

declare name_logdecoder$i=$(grep hostname: $(grep -w logdecoder: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8)

logdec[i]=$(eval echo \$logdecoder$i)
name_logdec[i]=$(eval echo \$name_logdecoder$i)
echo "${name_logdec[i]} ${logdec[i]}"
done
echo ""
sleep 1

# Broker
#========
cd /var/lib/puppet/yaml/node
range_brok=$(grep -w --exclude="$malware_uuid" --exclude="$sa_uuid" broker: * | wc -l)
echo ""
echo number_of_brokers=$range_brok
for ((i=1; i<=range_brok; i++)); do

declare broker$i=$(grep ipaddress: $(grep -w --exclude="$malware_uuid" --exclude="$sa_uuid" broker: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8  | cut -c 2- | rev | cut -c 2- | rev)

declare name_broker$i=$(grep hostname: $(grep -w --exclude="$malware_uuid" --exclude="$sa_uuid" broker: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8)

brok[i]=$(eval echo \$broker$i)
name_brok[i]=$(eval echo \$name_broker$i)
echo "${name_brok[i]} ${brok[i]}"
done
echo ""
sleep 1

# Malware-Analysis
#==================
cd /var/lib/puppet/yaml/node
range_mal=$(grep -w malware-analysis: * | wc -l)
echo ""
echo number_of_malware_analysis=$range_mal
for ((i=1; i<=range_mal; i++)); do

declare malware_analysis$i=$(grep ipaddress: $(grep -w malware-analysis: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8  | cut -c 2- | rev | cut -c 2- | rev)

declare name_malware_analysis$i=$(grep hostname: $(grep -w malware-analysis: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8)

mal[i]=$(eval echo \$malware_analysis$i)
name_mal[i]=$(eval echo \$name_malware_analysis$i)
echo "${name_mal[i]} ${mal[i]}"
done
echo ""
sleep 1

# Archiver
#==========
cd /var/lib/puppet/yaml/node
range_arc=$(grep -w archiver: * | wc -l)
echo ""
echo number_of_archivers=$range_arc
for ((i=1; i<=range_arc; i++)); do

declare archiver$i=$(grep ipaddress: $(grep -w archiver: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8  | cut -c 2- | rev | cut -c 2- | rev)

declare name_archiver$i=$(grep hostname: $(grep -w archiver: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8)

arc[i]=$(eval echo \$archiver$i)
name_arc[i]=$(eval echo \$name_archiver$i)
echo "${name_arc[i]} ${arc[i]}"
done
echo ""
sleep 1


# ESA
#=====
cd /var/lib/puppet/yaml/node
range_esa=$(grep -w esa: * | wc -l)
echo ""
echo number_of_esa=$range_esa
for ((i=1; i<=range_esa; i++)); do

declare esa$i=$(grep ipaddress: $(grep -w esa: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8  | cut -c 2- | rev | cut -c 2- | rev)

declare name_esa$i=$(grep hostname: $(grep -w esa: * | cut -d ':' -f1 | awk '{if (NR == lineNum) {print $0}}' lineNum=$i) | head -1 | cut -d " " -f8)

esa[i]=$(eval echo \$esa$i)
name_esa[i]=$(eval echo \$name_esa$i)
echo "${name_esa[i]} ${esa[i]}"
done
echo ""
sleep 1


echo ""
echo ""
echo ""
read -r -p "Are you sure the above devices are correct ? [y/N] " response
	case $response in
		[yY][eE][sS]|[yY])
			echo ""
			echo "Continuing at your choice"
			echo ""
			echo ""
			sleep 2
			;;
		*)
			echo ""
			echo "Exiting ...."
			echo ""
			sleep 2
			exit 1
			;;
	esac
#=============================================================================
#===========================  Checking Phase  ================================
#=============================================================================

# Check SSH connection to HOSTs
#===============================

echo "Checking SSH Connectivity to hosts"
echo "==================================="

# Decoder
#=========
if [[ $range_dec -ne 0 ]] ; then

declare -a s_dec
declare -a name_s_dec
declare -a f_dec
declare -a name_f_dec

		for (( j=1; j<=$range_dec; j++ ));do
		dec_connectivity="$(openssl s_client -connect ${dec[j]}:22 2> /dev/null| sed -n 1p | cut -c1-9)"
		
				if [ "$dec_connectivity" != "CONNECTED" ]
				then
				echo "WARN !! Please Check SSH connection to Decoder ${name_dec[j]} ${dec[j]}"
				f_dec[${#f_dec[@]}+1]=${dec[j]}
				name_f_dec[${#name_f_dec[@]}+1]=${name_dec[j]}
				echo  " "
				else
				echo "PASSED           Decoder ${name_dec[j]} ${dec[j]} is ssh accessible"
				s_dec[${#s_dec[@]}+1]=${dec[j]}
				name_s_dec[${#name_s_dec[@]}+1]=${name_dec[j]}
				echo  " "
				fi
		done
		
fi
sleep 1

	
# LogDecoder
#============
if [[ $range_logdec -ne 0 ]] ; then

declare -a s_logdec
declare -a name_s_logdec
declare -a f_logdec
declare -a name_f_logdec

		for (( j=1; j<=$range_logdec; j++ ));do
		logdec_connectivity="$(openssl s_client -connect ${logdec[j]}:22 2> /dev/null| sed -n 1p | cut -c1-9)"
		
				if [ "$logdec_connectivity" != "CONNECTED" ]
				then
				echo "WARN !! Please Check SSH connection to LogDecoder ${name_logdec[j]} ${logdec[j]}"
				f_logdec[${#f_logdec[@]}+1]=${logdec[j]}
				name_f_logdec[${#name_f_logdec[@]}+1]=${name_logdec[j]}
				echo  " "
				else
				echo "PASSED           LogDecoder ${name_logdec[j]} ${logdec[j]} is ssh accessible"
				s_logdec[${#s_logdec[@]}+1]=${logdec[j]}
				name_s_logdec[${#name_s_logdec[@]}+1]=${name_logdec[j]}
				echo  " "
				fi
		done

fi
sleep 1

# Concentrator
#==============
if [[ $range_conc -ne 0 ]] ; then

declare -a s_conc
declare -a name_s_conc
declare -a f_conc
declare -a name_f_conc

		for (( j=1; j<=$range_conc; j++ ));do
		conc_connectivity="$(openssl s_client -connect ${conc[j]}:22 2> /dev/null| sed -n 1p | cut -c1-9)"
		
				if [ "$conc_connectivity" != "CONNECTED" ]
				then
				echo "WARN !! Please Check SSH connection to Concentrator ${name_conc[j]} ${conc[j]}"
				f_conc[${#f_conc[@]}+1]=${conc[j]}
				name_f_conc[${#name_f_conc[@]}+1]=${name_conc[j]}
				echo  " "
				else
				echo "PASSED           Concentrator ${name_conc[j]} ${conc[j]} is ssh accessible"
				s_conc[${#s_conc[@]}+1]=${conc[j]}
				name_s_conc[${#name_s_conc[@]}+1]=${name_conc[j]}
				echo  " "
				fi
		done
		
fi
sleep 1


# Broker
#========
if [[ $range_brok -ne 0 ]] ; then

declare -a s_brok
declare -a name_s_brok
declare -a f_brok
declare -a name_f_brok

		for (( j=1; j<=$range_brok; j++ ));do
		brok_connectivity="$(openssl s_client -connect ${brok[j]}:22 2> /dev/null| sed -n 1p | cut -c1-9)"
		
				if [ "$brok_connectivity" != "CONNECTED" ]
				then
				echo "WARN !! Please Check SSH connection to Broker ${name_brok[j]} ${brok[j]}"
				f_brok[${#f_brok[@]}+1]=${brok[j]}
				name_f_brok[${#name_f_brok[@]}+1]=${name_brok[j]}
				echo  " "
				else
				echo "PASSED           Broker ${name_brok[j]} ${brok[j]} is ssh accessible"
				s_brok[${#s_brok[@]}+1]=${brok[j]}
				name_s_brok[${#name_s_brok[@]}+1]=${name_brok[j]}
				echo  " "
				fi
		done

fi
sleep 1


# Malware
#=========
if [[ $range_mal -ne 0 ]] ; then

declare -a s_mal
declare -a name_s_mal
declare -a f_mal
declare -a name_f_mal

		for (( j=1; j<=$range_mal; j++ ));do
		mal_connectivity="$(openssl s_client -connect ${mal[j]}:22 2> /dev/null| sed -n 1p | cut -c1-9)"
		
				if [ "$mal_connectivity" != "CONNECTED" ]
				then
				echo "WARN !! Please Check SSH connection to Malware ${name_mal[j]} ${mal[j]}"
				f_mal[${#f_mal[@]}+1]=${mal[j]}
				name_f_mal[${#name_f_mal[@]}+1]=${name_mal[j]}
				echo  " "
				else
				echo "PASSED           Malware ${name_mal[j]} ${mal[j]} is ssh accessible"
				s_mal[${#s_mal[@]}+1]=${mal[j]}
				name_s_mal[${#name_s_mal[@]}+1]=${name_mal[j]}
				echo  " "
				fi
		done

fi
sleep 1


# ESA
#=====
if [[ $range_esa -ne 0 ]] ; then

declare -a s_esa
declare -a name_s_esa
declare -a f_esa
declare -a name_f_esa

		for (( j=1; j<=$range_esa; j++ ));do
		esa_connectivity="$(openssl s_client -connect ${esa[j]}:22 2> /dev/null| sed -n 1p | cut -c1-9)"
		
				if [ "$esa_connectivity" != "CONNECTED" ]
				then
				echo "WARN !! Please Check SSH connection to ESA ${name_esa[j]} ${esa[j]}"
				f_esa[${#f_esa[@]}+1]=${esa[j]}
				name_f_esa[${#name_f_esa[@]}+1]=${name_esa[j]}
				echo  " "
				else
				echo "PASSED           ESA ${name_esa[j]} ${esa[j]} is ssh accessible"
				s_esa[${#s_esa[@]}+1]=${esa[j]}
				name_s_esa[${#name_s_esa[@]}+1]=${name_esa[j]}
				echo  " "
				fi
		done

fi
sleep 1



# Archiver
#==========
if [[ $range_arc -ne 0 ]] ; then

declare -a s_arc
declare -a name_s_arc
declare -a f_arc
declare -a name_f_arc

		for (( j=1; j<=$range_arc; j++ ));do
		arc_connectivity="$(openssl s_client -connect ${arc[j]}:22 2> /dev/null| sed -n 1p | cut -c1-9)"
		
				if [ "$arc_connectivity" != "CONNECTED" ]
				then
				echo "WARN !! Please Check SSH connection to Archiver ${name_arc[j]} ${arc[j]}"
				f_arc[${#f_arc[@]}+1]=${arc[j]}
				name_f_arc[${#name_f_arc[@]}+1]=${name_arc[j]}
				echo  " "
				else
				echo "PASSED           Archiver ${name_arc[j]} ${arc[j]} is ssh accessible"
				s_arc[${#s_arc[@]}+1]=${arc[j]}
				name_s_arc[${#name_s_arc[@]}+1]=${name_arc[j]}
				echo  " "
				fi
		done

fi
sleep 1




# Print Failing SSH devices
#===========================

if [[ ${#f_dec[@]} -ne 0 ]] ; then
echo "Please Check SSH Accessibility to these Decoders"
echo "================================================"
echo ${f_dec[@]}
echo ""
fi


if [[ ${#f_logdec[@]} -ne 0 ]] ; then
echo "Please Check SSH Accessibility to these LogDecoders"
echo "====================================================="
echo ${f_logdec[@]}
echo ""
fi


if [[ ${#f_conc[@]} -ne 0 ]] ; then
echo "Please Check SSH Accessibility to these Concentrators"
echo "====================================================="
echo ${f_conc[@]}
echo ""
fi


if [[ ${#f_brok[@]} -ne 0 ]] ; then
echo "Please Check SSH Accessibility to these Brokers"
echo "================================================"
echo ${f_brok[@]}
echo ""
fi


if [[ ${#f_mal[@]} -ne 0 ]] ; then
echo "Please Check SSH Accessibility to these Malwares"
echo "================================================"
echo ${f_mal[@]}
echo ""
fi


if [[ ${#f_esa[@]} -ne 0 ]] ; then
echo "Please Check SSH Accessibility to these ESA"
echo "============================================="
echo ${f_esa[@]}
echo ""
fi


if [[ ${#f_arc[@]} -ne 0 ]] ; then
echo "Please Check SSH Accessibility to these Archivers"
echo "================================================"
echo ${f_arc[@]}
echo ""
fi



# Make sure all devices are UP before updating,
# else ask the customer to continue at own risk.
#===============================================

if [[ ${#f_arc[@]}  -ne 0 ]] || [[ ${#f_esa[@]}  -ne 0 ]] || [[ ${#f_mal[@]}  -ne 0 ]] || [[ ${#f_brok[@]}  -ne 0 ]] || [[ ${#f_logdec[@]}  -ne 0 ]] || [[ ${#f_dec[@]}  -ne 0 ]] || [[ ${#f_conc[@]}  -ne 0 ]]; then

	echo ""
	# Print some scary stuff to continue update at own's risk
	#==========================================================
	echo "WARN !!! Some Devices aren't SSH Accessibile"
	echo "RSA Strongly Recommends that you update ALL your devices at the same time"
	read -r -p "Are you sure you wish to continue with upgrade ? [y/N] " response
		case $response in
			[yY][eE][sS]|[yY])
				echo ""
				echo "Continuing Update..."
				;;
			*)
				echo ""
				echo "Exiting ...."
				echo ""
				sleep 2
				exit 1
				;;
		esac

fi


#==========================================================================
#===========================  Updating Phase  =============================
#==========================================================================


# let the magic begin
#=====================

# Update Sequence
#================
# SA Appliance
# ESA, Malware
# Decoders
# Concentrators
# Archivers
# Brokers


echo ""
sleep 2
echo "Script will now proceed with the update process"
echo ""
read -rsp $'Press any key to continue...\n' -n1 key
sleep 1
echo .
sleep 1
echo .
sleep 1
echo .
sleep 1

echo ""
echo "Updating the devices in the following sequence"
echo "==============================================="
echo "Security Analytics server"
echo "Evenet Stream Analaysis"
echo "Malware"
echo "Decoders"
echo "Concentrators"
echo "Archivers"
echo "Brokers"


echo ""
read -r -p "Continue...? [y/N] " response
	case $response in
		[yY][eE][sS]|[yY])
			echo ""
			echo ""
			sleep 1
			;;
		*)
			echo ""
			echo "Exiting ...."
			echo ""
			sleep 2
			exit 1
			;;
	esac

	
sleep 2

# check SA repo is enabled, if not enabled, then enable it.
#=========================================================
echo ""
echo ""
echo "#######################################"
echo '#                                     #'
echo "#             SA Server               #"
echo "#                                     #"
echo "#                                     #"
echo "#######################################"
echo ""
echo ""
echo "Checking SA repo..."
echo "===================="
sa_repo_enable=$(grep enabled /etc/yum.repos.d/RSASoftware.repo | cut -c 9)
if [ $sa_repo_enable != 1 ]; then
        echo 'RSA Repo was disabled, enabling it...'
        sleep 2
        sed -i -- 's/enabled=0/enabled=1/g' /etc/yum.repos.d/RSASoftware.repo;
        echo 'Just Enabled RSA Repo for you...'
fi
echo "PASSED            SA repo check"
echo " "
echo ""
echo "Updating SA server..."
rm -f /var/run/yum.pid
yum install rsa-sa-gpg-pubkeys --nogpgcheck
echo ""
echo ""
echo "Updating SA Repo"
echo ""
sleep 3
yum clean all
yum update





# Create some temp scripts to be sent to each device type
#=========================================================


##========= ESA Script ===========

cat <<EOT > /tmp/U_esa

#! /bin/bash

echo " "
echo "checking ESA repo..."
repo_enable=\$(grep enabled /etc/yum.repos.d/RSASoftware.repo | cut -c 9)

if [[ \$repo_enable != 1 ]]; then
        echo 'ESA Repo was disabled, enabling it...'
        sleep 2
        sed -i -- 's/enabled=0/enabled=1/g' /etc/yum.repos.d/RSASoftware.repo;
        echo 'Enabled ESA Repo'
fi
echo "PASSED            ESA repo check"
echo  " "
echo  "Updating ESA"
rm -f /var/run/yum.pid
yum clean all
yum install rsa-sa-gpg-pubkeys --nogpgcheck -y
echo ""
echo ""
echo "Updating ESA \$HOSTNAME"
echo ""
sleep 3
echo ""
yum update -y


EOT

chmod +x /tmp/U_esa


##========= Malware Script ===========

cat <<EOT > /tmp/U_mal

#! /bin/bash

echo " "
echo "checking Malware repo..."
repo_enable=\$(grep enabled /etc/yum.repos.d/RSASoftware.repo | cut -c 9)

if [[ \$repo_enable != 1 ]]; then
        echo 'Malware Repo was disabled, enabling it...'
        sleep 2
        sed -i -- 's/enabled=0/enabled=1/g' /etc/yum.repos.d/RSASoftware.repo;
        echo 'Enabled Malware Repo'
fi
echo "PASSED            Malware repo check"
echo  " "
echo  "Updating Malware"
rm -f /var/run/yum.pid
yum install rsa-sa-gpg-pubkeys --nogpgcheck -y
echo ""
echo ""
echo "Updating Malware \$HOSTNAME"
echo ""
sleep 3
yum clean all
yum update -y

EOT

chmod +x /tmp/U_mal



##========= Decoder Script ===========

cat <<EOT > /tmp/U_dec

#! /bin/bash

echo " "
echo "checking Decoder repo..."
repo_enable=\$(grep enabled /etc/yum.repos.d/RSASoftware.repo | cut -c 9)

if [[ \$repo_enable != 1 ]]; then
        echo 'Decoder Repo was disabled, enabling it...'
        sleep 2
        sed -i -- 's/enabled=0/enabled=1/g' /etc/yum.repos.d/RSASoftware.repo;
        echo 'Enabled Decoder Repo'
fi
echo "PASSED            Decoder repo check"
echo  " "
echo  "Updating Decoder"
rm -f /var/run/yum.pid
yum install rsa-sa-gpg-pubkeys --nogpgcheck -y
echo ""
echo ""
echo "Updating Decoder \$HOSTNAME"
echo ""
sleep 3
yum clean all
yum update -y

EOT

chmod +x /tmp/U_dec



##========= Log Decoder Script ===========

cat <<EOT > /tmp/U_logdec

#! /bin/bash

echo " "
echo "checking Log Decoder repo..."
repo_enable=\$(grep enabled /etc/yum.repos.d/RSASoftware.repo | cut -c 9)

if [[ \$repo_enable != 1 ]]; then
        echo 'Log Decoder Repo was disabled, enabling it...'
        sleep 2
        sed -i -- 's/enabled=0/enabled=1/g' /etc/yum.repos.d/RSASoftware.repo;
        echo 'Enabled Log Decoder Repo'
fi
echo "PASSED            Log Decoder repo check"
echo  " "
echo  "Updating Log Decoder"
rm -f /var/run/yum.pid
yum install rsa-sa-gpg-pubkeys --nogpgcheck -y
echo ""
echo ""
echo "Updating LogDecoder \$HOSTNAME"
echo ""
sleep 3
yum clean all
yum update -y

EOT

chmod +x /tmp/U_logdec



##========= Concentrator Script ===========

cat <<EOT > /tmp/U_conc

#! /bin/bash

echo " "
echo "checking Concentrator repo..."
repo_enable=\$(grep enabled /etc/yum.repos.d/RSASoftware.repo | cut -c 9)

if [[ \$repo_enable != 1 ]]; then
        echo 'Concentrator Repo was disabled, enabling it...'
        sleep 2
        sed -i -- 's/enabled=0/enabled=1/g' /etc/yum.repos.d/RSASoftware.repo;
        echo 'Enabled Concentrator Repo'
fi
echo "PASSED            Concentrator repo check"
echo  " "
echo  "Updating Concentrator"
rm -f /var/run/yum.pid
yum install rsa-sa-gpg-pubkeys --nogpgcheck -y
echo ""
echo ""
echo "Updating Concentrator \$HOSTNAME"
echo ""
sleep 3
yum clean all
yum update -y

EOT

chmod +x /tmp/U_conc




##========= Archiver Script ===========

cat <<EOT > /tmp/U_arc

#! /bin/bash

echo " "
echo "checking Archiver repo..."
repo_enable=\$(grep enabled /etc/yum.repos.d/RSASoftware.repo | cut -c 9)

if [[ \$repo_enable != 1 ]]; then
        echo 'Archiver Repo was disabled, enabling it...'
        sleep 2
        sed -i -- 's/enabled=0/enabled=1/g' /etc/yum.repos.d/RSASoftware.repo;
        echo 'Enabled Archiver Repo'
fi
echo "PASSED            Archiver repo check"
echo  " "
echo  "Updating Archiver"
rm -f /var/run/yum.pid
yum install rsa-sa-gpg-pubkeys --nogpgcheck -y
echo ""
echo ""
echo "Updating Archiver \$HOSTNAME"
echo ""
sleep 3
yum clean all
yum update -y

EOT

chmod +x /tmp/U_arc



##========= Broker Script ===========

cat <<EOT > /tmp/U_brok

#! /bin/bash

echo " "
echo "checking Broker repo..."
repo_enable=\$(grep enabled /etc/yum.repos.d/RSASoftware.repo | cut -c 9)

if [[ \$repo_enable != 1 ]]; then
        echo 'Broker Repo was disabled, enabling it...'
        sleep 2
        sed -i -- 's/enabled=0/enabled=1/g' /etc/yum.repos.d/RSASoftware.repo;
        echo 'Enabled Broker Repo'
fi
echo "PASSED            Broker repo check"
echo  " "
echo  "Updating Broker"
rm -f /var/run/yum.pid
yum install rsa-sa-gpg-pubkeys --nogpgcheck -y
echo ""
echo ""
echo "Updating Broker \$HOSTNAME"
echo ""
sleep 3
yum clean all
yum update -y

EOT

chmod +x /tmp/U_brok






#=========================================================

# Updating ESA
#==============

if [[ ${#s_esa[@]}  -ne 0 ]]; then


echo ""
echo ""
echo "#######################################"
echo '#                                     #'
echo "#             ESA Server              #"
echo "#                                     #"
echo "#                                     #"
echo "#######################################"
echo ""
echo ""

		for ((k=1; k<=${#s_esa[@]}; k++)); do
		echo ""
		echo ""
		echo ""
		echo "Updating ${name_s_esa[k]} ${s_esa[k]}"
		echo ""
		echo ""
		ssh root@${s_esa[k]} 'bash -s' < /tmp/U_esa
		echo ""
		echo ""
		echo ""
		done
fi




# Updating Malware
#==================

if [[ ${#s_mal[@]}  -ne 0 ]]; then


echo ""
echo ""
echo "#######################################"
echo '#                                     #'
echo "#             Malware Server          #"
echo "#                                     #"
echo "#                                     #"
echo "#######################################"
echo ""
echo ""

		for ((k=1; k<=${#s_mal[@]}; k++)); do
		echo ""
		echo ""
		echo ""
		echo "Updating ${name_s_mal[k]} ${s_mal[k]}"
		echo ""
		echo ""
		ssh root@${s_mal[k]} 'bash -s' < /tmp/U_mal
		echo ""
		echo ""
		echo ""
		done
fi




# Updating Decoder
#=================

if [[ ${#s_dec[@]}  -ne 0 ]]; then


echo ""
echo ""
echo "#######################################"
echo '#                                     #'
echo "#             Decoder Server          #"
echo "#                                     #"
echo "#                                     #"
echo "#######################################"
echo ""
echo ""

		for ((k=1; k<=${#s_dec[@]}; k++)); do
		echo ""
		echo ""
		echo ""
		echo "Updating ${name_s_dec[k]} ${s_dec[k]}"
		echo ""
		echo ""
		ssh root@${s_dec[k]} 'bash -s' < /tmp/U_dec
		echo ""
		echo ""
		echo ""
		done
fi




# Updating Log Decoder
#======================

if [[ ${#s_logdec[@]}  -ne 0 ]]; then


echo ""
echo ""
echo "#######################################"
echo '#                                     #'
echo "#         Log Decoder Server          #"
echo "#                                     #"
echo "#                                     #"
echo "#######################################"
echo ""
echo ""

		for ((k=1; k<=${#s_logdec[@]}; k++)); do
		echo ""
		echo ""
		echo ""
		echo "Updating ${name_s_logdec[k]} ${s_logdec[k]}"
		echo ""
		echo ""
		ssh root@${s_logdec[k]} 'bash -s' < /tmp/U_logdec
		echo ""
		echo ""
		echo ""
		done
fi



# Updating Concentrator
#=======================

if [[ ${#s_conc[@]}  -ne 0 ]]; then


echo ""
echo ""
echo "#######################################"
echo '#                                     #'
echo "#        Concentrator Server          #"
echo "#                                     #"
echo "#                                     #"
echo "#######################################"
echo ""
echo ""

		for ((k=1; k<=${#s_conc[@]}; k++)); do
		echo ""
		echo ""
		echo ""
		echo "Updating ${name_s_conc[k]} ${s_conc[k]}"
		echo ""
		echo ""
		ssh root@${s_conc[k]} 'bash -s' < /tmp/U_conc
		echo ""
		echo ""
		echo ""
		done
fi




# Updating Archiver
#==================

if [[ ${#s_arc[@]}  -ne 0 ]]; then


echo ""
echo ""
echo "#######################################"
echo '#                                     #'
echo "#            Archiver Server          #"
echo "#                                     #"
echo "#                                     #"
echo "#######################################"
echo ""
echo ""

		for ((k=1; k<=${#s_arc[@]}; k++)); do
		echo ""
		echo ""
		echo ""
		echo "Updating ${name_s_arc[k]} ${s_arc[k]}"
		echo ""
		echo ""
		ssh root@${s_arc[k]} 'bash -s' < /tmp/U_arc
		echo ""
		echo ""
		echo ""
		done
fi




# Updating Broker
#================

if [[ ${#s_brok[@]}  -ne 0 ]]; then


echo ""
echo ""
echo "#######################################"
echo '#                                     #'
echo "#             Broker Server           #"
echo "#                                     #"
echo "#                                     #"
echo "#######################################"
echo ""
echo ""

		for ((k=1; k<=${#s_brok[@]}; k++)); do
		echo ""
		echo ""
		echo ""
		echo "Updating ${name_s_brok[k]} ${s_brok[k]}"
		echo ""
		echo ""
		ssh root@${s_brok[k]} 'bash -s' < /tmp/U_brok
		echo ""
		echo ""
		echo ""
		done
fi


#=============================== FINALIZING ============================

# Cleaning up the mess
#=======================

rm -f /tmp/U_esa /tmp/U_mal /tmp/U_dec /tmp/U_logdec /tmp/U_conc /tmp/U_arc /tmp/U_brok

unset s_dec;unset f_dec;unset s_logdec;unset f_logdec;unset s_conc;unset f_conc;unset s_brok;unset f_brok;unset s_mal;unset f_mal;unset s_esa;unset f_esa;unset s_arc;unset f_arc



# Offer to Reboot SA server
#===========================
echo "==================================================================="
echo ""
echo "Script has finished the process"
echo ""
echo "Do you wish to reboot the SA server now ?"
echo "It is highly recommended to reboot the machine after doing some upgrades"
echo ""
read -r -p "Are you sure you wish to REBOOT ? [y/N] " response
	case $response in
		[yY][eE][sS]|[yY])
			echo ""
			echo "Rebooting in 10 seconds..."
			sleep 10
			init 6
			;;
		*)
			echo ""
			echo "Exiting ...."
			echo ""
			sleep 2
			exit 1
			;;
	esac




#================================= END OF SCRIPT =================================
