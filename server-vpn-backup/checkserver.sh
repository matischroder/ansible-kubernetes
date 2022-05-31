#!/bin/bash
# /home/ubuntu/bin/checkserver.sh 
export KEEPALIVEDSTATUS=$(journalctl -u keepalived | grep Entering | awk 'END{print $8}')
while true 
do
    if [ $KEEPALIVEDSTATUS = 'MASTER' ]
    then
        python3 /home/ubuntu/bin/master.py
    fi
    while true
    do
            STATUS=$(journalctl -u keepalived | grep Entering | awk 'END{print $8}')
            if [ $KEEPALIVEDSTATUS != $STATUS ]
            then
                    case $STATUS in
                        "MASTER") python3 /home/ubuntu/bin/master.py
                                KEEPALIVEDSTATUS=MASTER
                                echo Changed to $KEEPALIVEDSTATUS
                                ;;
                        "BACKUP") KEEPALIVEDSTATUS=BACKUP
                                echo Changed to $KEEPALIVEDSTATUS
                                ;;
                        "FAULT") KEEPALIVEDSTATUS=FAULT
                                echo Changed to $KEEPALIVEDSTATUS
                                ;;
                        *)      echo "unknown state"
                                ;;
                    esac
                fi
                sleep 1
    done
 
    sleep 60
done
