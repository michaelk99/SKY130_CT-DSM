'''
Copyright 2023 Michael Koefinger
 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
 
     http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
'''

#!/usr/bin/python3
from __future__ import division
from scipy.io import savemat
from vcdvcd import VCDVCD
import sys
import numpy as np

''' Constants '''
INIT_IDX = 0
TIME_IDX = 0
VAL_IDX = 1
FS = 65536
TIMERES = 100 # nano sec
TIME_TOL = 0.1
TIMEUNIT = 1e-9

''' Methods '''
def getQuantizedTime(time, timeRes):
    qTime = int(time/timeRes)*timeRes
    return qTime

def mapCharVal2Int(char):
    if char == '0':
        val = 0b0
    elif char == '1':
        val = 0b1
    else:
        raise Exception
    return val

'''Start of vcd2mat script'''
vcdPathDbg = "eda/designs/mod/ctdsm4_test.vcd"

##############

assert(len(sys.argv) == 3), "Error! Check input arguments!\n Usage: python3 vcd2mat.py <vcdpath> <matpath>"

## Select device type and model
vcdPath = sys.argv[1]
outPath = sys.argv[2]

validDataKeys = ('b0', 'b1')
clockKey = 'clk'

## Init data structure
vcd = VCDVCD(vcdPath)
#keyList = vcd.references_to_ids.keys()
#timeScaleInfo = vcd.timescale['timescale']

try:
    clk = vcd[clockKey].tv
    dataList = [vcd[validDataKeys[0]].tv, vcd[validDataKeys[1]].tv]
except:
    raise Exception

bitVecLen = len(clk)//2+1
dataSet = []
statCnt = np.array([0,0])
statIdx = -1
for tvList in dataList:
    # init data and time with initial value (at t=0), not a true event
    bitVec = [mapCharVal2Int(tvList[INIT_IDX][VAL_IDX])]
    prevClkTime = tvList[INIT_IDX][TIME_IDX]
    statIdx = statIdx + 1
    for i in range(INIT_IDX+1, len(tvList)):
        if i == INIT_IDX+1:
            clkTime = getQuantizedTime(clk[i][TIME_IDX], TIMERES)
        else:
            clkTime = getQuantizedTime(prevClkTime+1/FS/TIMEUNIT, TIMERES)

        evtTime = getQuantizedTime(tvList[i][TIME_IDX], TIMERES)
        #nxtEvtTime = getQuantizedTime(tvList[i+1][TIME_IDX], TIMERES)

        if evtTime > getQuantizedTime(clkTime+0.5/FS/TIMEUNIT, TIMERES):
            timeDiff = abs(evtTime - clkTime)
            periodCnt = int(np.round(timeDiff*FS*TIMEUNIT))
            bitVec.extend([bitVec[len(bitVec)-1]]*periodCnt)
            statCnt[statIdx] = statCnt[statIdx] + periodCnt
        elif evtTime < getQuantizedTime(clkTime, TIMERES):
            # last event was not valid, delete last added item
            if (evtTime >= prevClkTime-5*TIMERES) & (evtTime <= prevClkTime+5*TIMERES):
                statCnt[statIdx] = statCnt[statIdx] - 1
                bitVec.pop()
                    
        bitVec.append(mapCharVal2Int(tvList[i][VAL_IDX]))
        statCnt[statIdx] = statCnt[statIdx] + 1
        prevClkTime = evtTime
    
    # Check if last event occurs before last clock cycle, extend accordingly
    # bit0 adds one too much!
    lastClkTime = getQuantizedTime(clk[-1][TIME_IDX], TIMERES)
    timeDiff = abs(evtTime - lastClkTime)
    periodCnt = int(np.round(timeDiff*FS*TIMEUNIT))
    if periodCnt > 0:
        # "hacky" fix of unreliable result of rounding operation
        errLen = abs(bitVecLen - (len(bitVec)+periodCnt))
        periodCnt = periodCnt - errLen
        bitVec.extend([bitVec[len(bitVec)-1]]*periodCnt)
        statCnt[statIdx] = statCnt[statIdx] + periodCnt
    
    dataSet.append(bitVec)

if len(dataSet[0]) != len(dataSet[1]):
    raise Exception

# combine bit vectors
dataVec = np.zeros((len(dataSet[0]),1))

for i in range(len(dataVec)):
    dataVec[i] = (dataSet[1][i] << 1) | (dataSet[0][i])

savemat(outPath, {"data":dataVec})


##############