import serial
import re
from timeit import default_timer as timer
from statistics import fmean
sensora = serial.Serial(port="COM13", baudrate=9600)
sensorb = serial.Serial(port="COM14", baudrate=9600)
sensors = [sensora,sensorb]
start=timer()
still=0
state=0
#states:
#0 = calibration
#1 = curling


prev_average = [[0,0,0],[0,0,0]]# 2 sensors, 3 previous average values (heading, pitch, roll)
data_average = [[0,0,0],[0,0,0]]# 2 sensors, 3 current average values (heading, pitch, roll)

data = [[[],[],[]],[[],[],[]]]# 2 sensors, 3 running lists per sensor (heading, pitch, roll)


import sys
debug = False  
if(len(sys.argv)>1):
    debug=sys.argv[1]

print("Please hold still in rest position for (3) seconds.")

while(True):
    for sensor in sensors: # if data, read it
        if sensor.in_waiting > 0:
            
            # Read data from buffer until return/newline found
            serialString = sensor.readline()
            # print(serialString.decode("Ascii").strip().split('\t'))
            try:
                input = serialString.decode("Ascii")
                node,heading_str,pitch_str,roll_str = input.strip().split('\t')
                heading = float(heading_str[9:])# "heading: xxxx.xxxx"
                pitch = float(pitch_str[7:])    # "pitch: xxxx.xxxx"
                roll = float(roll_str[6:])      # "roll: xxxx.xxxx"
                if(node=="Node1"):
                    i_n=0
                elif(node=="Node2"):
                    i_n=1
                else:
                    raise SystemExit("not valid node name")
            
                if(debug):
                    print("NODE",i_n+1,heading,pitch,roll)
            
                data[i_n][0].append(heading)
                data[i_n][1].append(pitch)
                data[i_n][2].append(roll)
                
                
            except:
                pass
            
            
    now=timer()
    if((now-start)>.1):
        # print(".1 second has passed")
        start=timer()
        
        try: 
            tmp_data_average = [[fmean(data[i_n][s_v]) for s_v in range(3)] for i_n in range(len(sensors))]
        except:
            print("no data")
            continue
        
        prev_average = data_average
              
        data_average = tmp_data_average
        
        if(state==0):# calibration state
            if(debug):
                print(abs(data_average[0][0]-data_average[1][0]), abs(data_average[0][2]-data_average[1][2]),abs(data_average[0][1]-data_average[1][1]))
            # if(abs(data_average[0][0]-prev_average[0][0])<1 and abs(data_average[0][2]-prev_average[0][2])<1 and abs(data_average[0][1]-prev_average[0][1])<1):
            #     still=still+1
            # else:
            #     still=0
            # if(still>=30):
            #     start_y,start_p,start_r = data_average[0][0],data_average[0][1],data_average[0][2]
            #     print("calibration complete, starting point = ",data_average[0][0],data_average[0][1],data_average[0][2])
            #     state=1
            #     curls=0
            #     still=0
            still=30
            # if(abs(data_average[0][0]-data_average[1][0])<10 and abs(data_average[0][2]-data_average[1][2])<10 and abs(data_average[0][1]-data_average[1][1])<10):
            #     still=still+1
            # else:
            #     still=0
            
            if(still>=30):
                # start_y,start_p,start_r = data_average[0][0],data_average[0][1],data_average[0][2]
                print("calibration complete")
                state=1
                curls=0
                still=0
        elif(state==1):# after calibration, down state
            dy,dp,dr=abs(data_average[0][0]-data_average[1][0]),abs(data_average[0][1]-data_average[1][1]),abs(data_average[0][2]-data_average[1][2])
            
            if(debug):
                print(dy,dp,dr)
                
            if(dp>60):
                state=2 #up state
                holdup=0
            # else: 
                # if(abs(data_average[0][0]-prev_average[0][0])<1 and abs(data_average[0][2]-prev_average[0][2])<1 and abs(data_average[0][1]-prev_average[0][1])<1 and abs(data_average[0][1])<5):
                #     still=still+1
                # else:
                #     still=0
                # if(still>=30):
                #     start_y,start_p,start_r = data_average[0][0],data_average[0][1],data_average[0][2]
                #     if(debug):
                #         print("calibration complete, starting point = ",data_average[0][0],data_average[0][1],data_average[0][2])
                #     still=0
        elif(state==2):
            dy,dp,dr=abs(data_average[0][0]-data_average[1][0]),abs(data_average[0][1]-data_average[1][1]),abs(data_average[0][2]-data_average[1][2])
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
        data[0][0]=[]
        data[0][1]=[]
        data[0][2]=[]
    # else:
            
