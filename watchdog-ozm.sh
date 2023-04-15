#!/bin/bash

# Set location of log file

shopt -s expand_aliases
alias mstart='sudo su minerstat -c "screen -X -S minerstat-console quit" > /dev/null 2>&1; cd /home/minerstat/minerstat-os/; sudo node stop > /dev/null 2>&1; sudo rm /tmp/stop.pid > /dev/null 2>&1; sudo rm /dev/shm/maintenance.pid > /dev/null 2>&1; sleep 1; sudo bash /home/minerstat/minerstat-os/validate.sh; screen -A -m -d -S minerstat-console sudo bash start.sh; echo "Minerstat has been re(started)! type: miner to check output, anytime!"; sleep 1; '


log_file=/home/minerstat/minerstat-os/clients/onezero-custom/miner.log                                                                                                                                            
ozmlogger=/home/minerstat/minerstat-os/ozm-logger.txt
# Set time threshold in seconds (4 minutes = 240 seconds recommended depending on difficulty)
time_threshold=240
#time=$(date +%F_%H:%M:%S)
#delta=$(grep -i 'Share' "$log_file" |tail -1)

exec &> >(tee -a "$ozmlogger")

while true; do
	time=$(date +%F_%H:%M:%S)
	delta=$(grep -i 'Share' "$log_file" |tail -1)
	error=$(grep -i 'panicked' "$log_file" |tail -3)
	echo "Watchdog is running AT = $time"
	echo "Last Share = $delta"


	  # Get current timestamp in seconds since epoch
	    current_time=$(date +%s)
	      # Search log file for "Share Accepted" and extract timestamp
	        timestamp=$(grep -oP '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(?=.*Share Accepted)' "$log_file" | tail -1)
		  # Convert timestamp to seconds since epoch
		    timestamp_seconds=$(date -d "$timestamp" +%s)
		      # Calculate time difference between current time and timestamp
		        time_difference=$((current_time - timestamp_seconds))
			  # If time difference is greater than time threshold, execute mstart
			    if [[ $time_difference -gt $time_threshold ]]; then
				    echo "mstart initiate"
				    mstart 
			    elif grep -q "panicked" "$log_file"  ; then
				    echo "OZM Panicked Error occured" 
				    echo "$error"
				    echo "Execute mstart"
				    mstart
					  fi
					  echo "Miner is OK"
					
		  # Wait for 60 seconds before checking again
					      sleep 60
				      done
