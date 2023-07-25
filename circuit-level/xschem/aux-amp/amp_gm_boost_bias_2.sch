v {xschem version=3.1.0 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 1330 400 1330 450 {
lab=VSS}
N 1310 450 1330 450 {
lab=VSS}
N 1250 350 1250 400 {
lab=VBIAS_N}
N 1310 470 1310 480 {
lab=VSS}
N 1150 -160 1150 -140 {
lab=VDD}
N 940 -160 960 -160 {
lab=VDD}
N 820 -160 940 -160 {
lab=VDD}
N 960 -160 980 -160 {
lab=VDD}
N 980 -160 1260 -160 {
lab=VDD}
N 1310 230 1310 270 {
lab=VBIAS_N}
N 1310 330 1310 370 {
lab=#net1}
N 1310 300 1330 300 {
lab=VSS}
N 1330 300 1330 400 {
lab=VSS}
N 1250 250 1250 350 {
lab=VBIAS_N}
N 1250 250 1310 250 {
lab=VBIAS_N}
N 1190 300 1270 300 {
lab=VCASC_N}
N 1150 230 1150 270 {
lab=VCASC_N}
N 1150 250 1210 250 {
lab=VCASC_N}
N 1210 250 1210 300 {
lab=VCASC_N}
N 1090 250 1150 250 {
lab=VCASC_N}
N 1150 -140 1150 70 {
lab=VDD}
N 1310 250 1320 250 {
lab=VBIAS_N}
N 1320 250 1340 250 {
lab=VBIAS_N}
N 1150 440 1150 480 {
lab=VSS}
N 1130 410 1150 410 {
lab=VSS}
N 1130 410 1130 460 {
lab=VSS}
N 1130 460 1150 460 {
lab=VSS}
N 1130 300 1150 300 {
lab=VSS}
N 1130 300 1130 410 {
lab=VSS}
N 1150 330 1150 380 {
lab=#net2}
N 1190 410 1210 410 {
lab=VCASC_N}
N 1210 300 1210 410 {
lab=VCASC_N}
N 1250 410 1270 410 {
lab=VBIAS_N}
N 1250 400 1250 410 {
lab=VBIAS_N}
N 1310 370 1310 380 {
lab=#net1}
N 1310 440 1310 470 {
lab=VSS}
N 1310 410 1330 410 {
lab=VSS}
N 1310 -160 1310 -110 {
lab=VDD}
N 1310 -80 1340 -80 {
lab=VDD}
N 1340 -160 1340 -80 {
lab=VDD}
N 1150 70 1150 170 {
lab=VDD}
N 1250 -80 1270 -80 {
lab=VBIAS_P}
N 1310 -10 1340 -10 {
lab=VBIAS_P}
N 960 230 960 480 {
lab=VSS}
N 960 60 960 170 {
lab=VCASC_P}
N 960 -150 960 -110 {
lab=VDD}
N 960 -160 960 -150 {
lab=VDD}
N 960 -50 960 0 {
lab=#net3}
N 1030 30 1030 90 {
lab=VCASC_P}
N 960 90 1030 90 {
lab=VCASC_P}
N 1000 -80 1030 -80 {
lab=VCASC_P}
N 1030 -80 1030 30 {
lab=VCASC_P}
N 940 -80 960 -80 {
lab=VDD}
N 940 -160 940 -80 {
lab=VDD}
N 940 30 960 30 {
lab=VDD}
N 940 -80 940 30 {
lab=VDD}
N 1260 -160 1340 -160 {
lab=VDD}
N 1000 30 1030 30 {
lab=VCASC_P}
N 1250 -10 1310 -10 {
lab=VBIAS_P}
N 1250 -80 1250 -10 {
lab=VBIAS_P}
N 820 480 1310 480 {
lab=VSS}
N 1340 -10 1450 -10 {
lab=VBIAS_P}
N 1340 250 1450 250 {
lab=VBIAS_N}
N 1090 150 1090 250 {
lab=VCASC_N}
N 1090 150 1450 150 {
lab=VCASC_N}
N 1030 90 1450 90 {
lab=VCASC_P}
N 1310 -50 1310 -10 {
lab=VBIAS_P}
N 1310 -10 1310 170 {
lab=VBIAS_P}
C {sky130_fd_pr/nfet_01v8.sym} 1290 300 0 0 {name=Mn2
L=1.5
W=2
nf=2
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 1170 300 0 1 {name=Mn4
L=1.5
W=2
nf=2
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {devices/isource.sym} 1150 200 0 0 {name=ICASCn value=150n}
C {sky130_fd_pr/nfet_01v8.sym} 1290 410 0 0 {name=Mn1
L=80
W=8
nf=8
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {devices/isource.sym} 1310 200 0 0 {name=IMAIN2 value=50n}
C {sky130_fd_pr/nfet_01v8.sym} 1170 410 0 1 {name=Mn3
L=80
W=8
nf=8
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/pfet_01v8.sym} 1290 -80 0 0 {name=Mp1
L=10
W=1
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {devices/isource.sym} 960 200 0 0 {name=ICASCp value=110n}
C {sky130_fd_pr/pfet_01v8.sym} 980 -80 0 1 {name=Mp3
L=80
W=10
nf=10
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/pfet_01v8.sym} 980 30 0 1 {name=Mp4
L=3.5
W=2
nf=2
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {devices/opin.sym} 1450 -10 0 0 {name=p4 lab=VBIAS_P}
C {devices/ipin.sym} 820 480 0 0 {name=p9 lab=VSS}
C {devices/ipin.sym} 820 -160 0 0 {name=p10 lab=VDD}
C {devices/opin.sym} 1450 250 0 0 {name=p1 lab=VBIAS_N}
C {devices/opin.sym} 1450 150 0 0 {name=p2 lab=VCASC_N}
C {devices/opin.sym} 1450 90 0 0 {name=p11 lab=VCASC_P}
