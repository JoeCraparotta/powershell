###################################
# icinga auto config generator
#
# Created by Joe.CPUraparotta 12/16/14
#
# Change lines shown below
#
#################################
#Change to server name you want
#Import From AD
#$servers = (Get-ADComputer -LDAPFilter "(name=server*)").Name 
#Import from txt file
$servers = get-content servers.txt
#>>>>> Change this<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$members=""
###########################################
# Create Host section
#
$line="#################`n
# Hosts"
$line1="define host {"
$line2="use             windows-server"
#>>>>> Change this<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$line3="hostgroups      Server Printing"
$line4="host_name       "
$line5="alias           "
$line6="address         "
$line7="}"
$line8=""
$line9="`n
###################`n
# Hostgroup`n
define hostgroup {"
#>>>>> Change this<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$line10 = "hostgroup_name                 Server Printing"
#>>>>> Change this<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$line11 = "alias                          Infrastructure"
$line12 = "members                        "
$line13 = "`n
######################`n
# Services`n
"


#############################################################
# Start Script
#
#####################################
$line |out-file icinga.txt -append
foreach ($server in $servers)
	{
	$members+=$server + ","
	if (test-connection -quiet -count 1 -computer $server)
		{
		
					$Ip=[System.Net.Dns]::GetHostAddresses("$server")
					$serverip = $ip.IPAddressToString
					$line1 |out-file icinga.txt -append
					$line2 |out-file icinga.txt -append
					$line3 |out-file icinga.txt -append
					$line4 + $server|out-file icinga.txt -append
					$line5 + $server |out-file icinga.txt -append
					$line6 + $serverip|out-file icinga.txt -append
					$line7 |out-file icinga.txt -append
					$line8 |out-file icinga.txt -append
					}
	else
		{
		}
		
	}
##################################
#members section	
	$line9 |out-file icinga.txt -append
	$line10 |out-file icinga.txt -append
	$line11 |out-file icinga.txt -append
	$line12 + $members |out-file icinga.txt -append
	$line7 |out-file icinga.txt -append
	$line8 |out-file icinga.txt -append
##################################
#services section
$server=""
$line13 |out-file icinga.txt -append

foreach ($server in $servers)
	{
if (test-connection -quiet -count 1 -computer $server)
					{
					#[string]$mac = .\psexec \\$server powershell "Get-WmiObject win32_networkadapterconfiguration -Filter 'ipenabled = "true"' |select MACAddress"
					#$mac = $mac.Substring(161,17)
$services="#$server

define service {
    use                      local-service
    host_name                $server
    service_description      PING
    check_command            check_ping!100.0,20%!500.0,60%
   }

 define service {`n
	use 	              local-service
	host_name             $server
	service_description 	IO C:
	check_command 	check_win_io!logical!C:
}
define service {
	use local-service
	service_description Disk Space - All
	host_name $server
	check_command check_win_disk!.!80!90!-o 1 -3 1
}
define service {
	use local-service
	service_description Uptime
	host_name $server
	check_command check_win_uptime!5min:!15min:
}
define service {
	use local-service
	host_name $server
	service_description RAM Utilisation
	check_command check_win_mem!90!95
}
define service {
	use local-service
	host_name $server
	service_description Network Interface NIC Team
	check_command check_win_network!.
}
define service {
	use local-service
	host_name $server
	service_description CPU Utilisation
	check_command check_win_cpu!80!90
}" |out-file icinga.txt -append
}
	else
		{
		}
} 
#eof



