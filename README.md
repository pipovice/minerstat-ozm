# minerstat-ozm
Fix for Onezerominer under Minerstat DNX solve

Miner either Stops accepting shares but hashes away on the same power or a System Error "panicked at" occurs and the miner also stops accepting shares even tho it calculates Jobs on Full Power.

![grafik](https://user-images.githubusercontent.com/130800379/232163874-eba79361-90ba-4f0d-a02f-190d3721f61a.png)

This is a "quick and Dirty" Fix for the reoccuring Problem on Minerstat using OneZeroMiner for the Dynex Algorythm. 
We have no further Infos why the error occures and on top it seems to be a minerstat only Problem. 

This is why i created this Script which works only on MSOS Rigs using OneZerominer 1.0.3

DISCLAIMER!!!! 
I Have to mention that i run this on MSOS 1.9.0 it might not work on MSOS 1.8.X or older with older Linux kernels(18.04.6 LTS/5.4.175-generic). 
I havent tried that, so let me know if there are different outcomes.

![grafik](https://user-images.githubusercontent.com/130800379/232209185-508a93b2-286d-4304-b3d2-f6cca34534f8.png)

The script is Setup to use the Minerstat mstart command which either starts the Miner or restarts it. 

I try to use an "easy" install guide but im not a pro Dev so please forgive me if i assume stuff that others dont know :)

First download the watchdog-ozm.sh bash script

copy/move it onto your Minerstat rig by using putty / winscp for example when you use linux to linux scp (download directory)/watchdog-ozm.sh minerstat@(rig-IP):/home/minerstat/minerstat-os

when you are on your Rigs console use pwd to see your parrent Directory where the script should be copied to 
![grafik](https://user-images.githubusercontent.com/130800379/232209220-813df589-993b-4277-a7a6-d7d6a14b517c.png)
  
  Now locate the Onezerominer Logfile (miner.log)
  
  ![grafik](https://user-images.githubusercontent.com/130800379/232209313-bb44ddc3-0289-4e06-99a1-9fad92fcc7a6.png)

copy the full path i.e /home/minerstat/minerstat-os/clients/onezero-custom/miner.log 

open the script with the vi editor or nano (vi watchdog-ozm.sh)

![grafik](https://user-images.githubusercontent.com/130800379/232209505-10420519-5fd9-4e84-9879-cfa6c7bff32e.png)

search for the log_file variable and replace the path

![grafik](https://user-images.githubusercontent.com/130800379/232209598-2659f8bf-f6b2-4b93-9143-6d0ee35c9bbc.png)

time_treshold = This gives the seconds inbetween "Share accepted" as an inactivity Delta. (once the script is not seeing an new shares for example 200 Seconds it restarts the Miner)
Set your threshold i recon depending on hardware and adjusted pool difficulty to set it to 4minutes so restarts dont happen by accident

![grafik](https://user-images.githubusercontent.com/130800379/232209661-a17a6162-316d-404d-ba4c-99b31a7c922c.png)


This is why the Alias environment has been added to the script.
when implementing check the following destinations and or variables.

ozmlogger is just a location to log the output of the script, it should also log the errors if they appear in the miner.log
You will be able to check the Scripts Log at this location 
/home/minerstat/minerstat-os/ozm-logger.txt

once The script adjustments are done you can proceed by opening a Screen session (please dont use Watchdog as VaderPanda mentioned that this can be its own session under minerstat

something like this 
Screen -S (session Name) 

![grafik](https://user-images.githubusercontent.com/130800379/232210294-be85926f-bd8c-4751-902c-843d27ed41e4.png)

now you are in the new screen session 
![grafik](https://user-images.githubusercontent.com/130800379/232210337-c342dfd3-3187-43da-9d47-1ed05eaef989.png)

Give the Script executable permissions via chmod 777 watchdog-ozm.sh

ready to start the Script

![grafik](https://user-images.githubusercontent.com/130800379/232210413-b0adc851-69da-4bb6-b7be-b66cbf7637b7.png)


check if output looks like this:
![grafik](https://user-images.githubusercontent.com/130800379/232163682-b6469752-f57b-4f97-9796-172745b6a429.png)


If it does exit the screen by pressing simultaneously CTRL+A+D

you are on the main Session again 

the screens of your environment should look something like this 

![grafik](https://user-images.githubusercontent.com/130800379/232223333-05473c32-cc92-4ded-b18c-bee231796abf.png)


Basic Function Chart: 

1. If time to last "share accepted" is more than $200 Seconds then restart miner
2. else if the word Panicked appears in the Log file restart the miner
3. if none of the above wait 10 Seconds and check again

![grafik](https://user-images.githubusercontent.com/130800379/232166215-b521cbbb-7402-44b7-ace9-3c88a15dbc0e.png)



exit screen with Ctrl+a+d

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
