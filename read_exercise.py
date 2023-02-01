import serial
import re
from timeit import default_timer as timer
from statistics import fmean
sensor = serial.Serial(port="COM8", baudrate=9600)
start=timer()
yav=pav=rav=yaw=pitch=roll=0
yaws=[]
pitches=[]
rolls=[]
still=0
state=0
#states:
#0 = calibration
#1 = curling


import sys
debug = False  
if(len(sys.argv)>1):
    debug=sys.argv[1]

print("Please hold still in rest position for (3) seconds.")

while(True):
    if sensor.in_waiting > 0: # if there is data, read it
        # Read data out of the buffer until a carraige return / new line is found
        serialString = sensor.readline()
        
        try:
            input = serialString.decode("Ascii")
            _,yaw,pitch,roll,_ = re.split(' |\r\n',input)
        except:
            pass
        
        # print(yaw,pitch,roll)
        yaws.append(float(yaw))
        pitches.append(float(pitch))
        rolls.append(float(roll))
        now=timer()
        if((now-start)>.1):
            # print(".1 second has passed")
            start=timer()
            pyav,ppav,prav= yav,pav,rav # previous values, to check for movement
            yav,pav,rav = fmean(yaws),fmean(pitches),fmean(rolls)            
            
            
            
            if(state==0):# calibration state
                if(debug):
                    print(yav,pav,rav)
                if(abs(yav-pyav)<1 and abs(rav-prav)<1 and abs(pav-ppav)<1):
                    still=still+1
                else:
                    still=0
                if(still>=30):
                    start_y,start_p,start_r = yav,pav,rav
                    print("calibration complete, starting point = ",yav,pav,rav)
                    state=1
                    curls=0
                    still=0
            elif(state==1):# after calibration, down state
                dy,dp,dr=abs(yav-start_y),abs(pav-start_p),abs(rav-start_r)
                
                if(debug):
                    print(dy,dp,dr)
                    
                if(dp>60):
                    state=2 #up state
                    holdup=0
                else: 
                    if(abs(yav-pyav)<1 and abs(rav-prav)<1 and abs(pav-ppav)<1 and abs(pav)<5):
                        still=still+1
                    else:
                        still=0
                    if(still>=30):
                        start_y,start_p,start_r = yav,pav,rav
                        if(debug):
                            print("calibration complete, starting point = ",yav,pav,rav)
                        still=0
            elif(state==2):
                dy,dp,dr=abs(yav-start_y),abs(pav-start_p),abs(rav-start_r)
                holdup=holdup+1
                if(debug):
                    print(dy,dp,dr)
                if(dp<15): #go to finish state
                    state=3
            elif(state==3):# finish rep state
                curls=curls+1
                print("curl number",curls,"held for",holdup/10,"seconds")
                state=1 # go back to down state for next rep
                    
            # reset collection of values used to calculate average  over .1 seconds
            yaws=[]
            pitches=[]
            rolls=[]
        # else:
            
