# minerstat-ozm
Fix for Onezerominer under Minerstat DNX solve

Miner either Stops accepting shares but hashes away on the same power or a System Error "panicked at" occurs and the miner also stops accepting shares even tho it calculates Jobs on Full Power.

![grafik](https://user-images.githubusercontent.com/130800379/232163874-eba79361-90ba-4f0d-a02f-190d3721f61a.png)

This is a "quick and Dirty" Fix for the reoccuring Problem on Minerstat using OneZeroMiner for the Dynex Algorythm. 
We have no further Infos why the error occures and on top it seems to be a minerstat only Problem. 

This is why i created this Script which works only on MSOS Rigs using OneZerominer 1.0.3

The script is Setup to use the Minerstat mstart command which either starts the Miner or restarts it. This is why the Alias environment has been added to the script.
when implementing check the following destinations and or variables.

log_file = this should be the absolute Path to the OZM miner.log (in the Minerstat default case /home/minerstat/minerstat-os/clients/onezero-custom/miner.log)
time_treshold = This gives the seconds inbetween "Share accepted" as an inactivity Delta. (once the script is not seeing an new shares for example 200 Seconds it restarts the Miner)

ozmlogger is just a location to log the output of the script, it should also log the errors if they appear in the miner.log

Basic Function Chart: 

1. If time to last "share accepted" is more than $200 Seconds then restart miner
2. else if the word Panicked appears in the Log file restart the miner
3. if none of the above wait 10 Seconds and check again


Just copy the Code or download the .sh file put it in your Minerstat OS home folder /home/minerstat/minerstat-os/ 
start a Screen so the script has its own session: screen -S watchdog 
enter the screen: screen -x watchdog 
start the script ./watchdog-ozm.sh

check if output looks something like this:
![grafik](https://user-images.githubusercontent.com/130800379/232163682-b6469752-f57b-4f97-9796-172745b6a429.png)

exit screen with Ctrl+a+d

              #!/bin/bash

              # Set location of log file

              shopt -s expand_aliases
              alias mstart='sudo su minerstat -c "screen -X -S minerstat-console quit" > /dev/null 2>&1; cd /home/minerstat/minerstat-os/; sudo node stop > /dev/null 2>&1; sudo rm /tmp/stop.pid > /dev/null 2>&1; sudo rm /dev/shm/maintenance.pid > /dev/null 2>&1; sleep 1; sudo bash /home/minerstat/minerstat-os/validate.sh; screen -A -m -d -S minerstat-console sudo bash start.sh; echo "Minerstat has been re(started)! type: miner to check output, anytime!"; sleep 1; '
              

               log_file=/home/minerstat/minerstat-os/clients/onezero-custom/miner.log                                                                                                                       
                ozmlogger=/home/minerstat/minerstat-os/ozm-logger.txt
                # Set time threshold in seconds (4 minutes = 240 seconds recommended depending on difficulty)
                time_threshold=200
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
                                              sleep 10
                                      done
