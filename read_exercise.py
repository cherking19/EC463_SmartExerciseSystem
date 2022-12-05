import serial
import re
from timeit import default_timer as timer
from statistics import fmean
sensor = serial.Serial(port="COM3", baudrate=9600)
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
while(True):
    if sensor.in_waiting > 0:
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
            pyav,ppav,prav= yav,pav,rav
            yav,pav,rav = fmean(yaws),fmean(pitches),fmean(rolls)            
            
            if(state==0):
                print(yav,pav,rav)
                if(abs(yav-pyav)<1 and abs(rav-prav)<1 and abs(pav-ppav)<1):
                    still=still+1
                if(still>=30):
                    start_y,start_p,start_r = yav,pav,rav
                    print("calibration complete, starting point = ",yav,pav,rav)
                    state=1
                    curls=0
            elif(state==1):
                dy,dp,dr=abs(yav-start_y),abs(pav-start_p),abs(rav-start_r)
                
                # print(dy,dp,dr)
                if(dp>60):
                    state=2
                holdup=0
            elif(state==2):
                dy,dp,dr=abs(yav-start_y),abs(pav-start_p),abs(rav-start_r)
                holdup=holdup+1
                if(dp<15):
                    state=3
            elif(state==3):
                curls=curls+1
                print("curl number",curls,"held for",holdup/10,"seconds")
                state=1
                    
                
            yaws=[]
            pitches=[]
            rolls=[]
        # else:
            