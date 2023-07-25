v {xschem version=3.1.0 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -60 120 -40 120 {
lab=#net1}
N -40 70 -40 120 {
lab=#net1}
N -60 70 -40 70 {
lab=#net1}
N 140 120 160 120 {
lab=#net1}
N 140 70 140 120 {
lab=#net1}
N 140 70 160 70 {
lab=#net1}
N -120 120 -100 120 {
lab=VI_P}
N 200 120 220 120 {
lab=#net2}
N 160 70 160 90 {
lab=#net1}
N -60 70 -60 90 {
lab=#net1}
N 30 -60 50 -60 {
lab=VDD}
N -60 40 -60 70 {
lab=#net1}
N 420 -10 580 -10 {
lab=VCASC_P}
N 420 130 580 130 {
lab=VCASC_N}
N 420 -110 580 -110 {
lab=#net3}
N 40 -160 620 -160 {
lab=VDD}
N 620 -160 620 -140 {
lab=VDD}
N 380 -160 380 -140 {
lab=VDD}
N 380 -80 380 -40 {
lab=#net4}
N 380 20 380 100 {
lab=#net3}
N 620 20 620 100 {
lab=VO}
N 620 -80 620 -40 {
lab=#net5}
N 620 260 620 280 {
lab=VSS}
N 380 260 380 280 {
lab=VSS}
N 380 160 380 200 {
lab=#net6}
N 620 160 620 200 {
lab=#net7}
N 420 230 580 230 {
lab=VBIAS_N}
N -60 40 140 40 {
lab=#net1}
N 160 160 160 170 {
lab=#net7}
N 160 170 620 170 {
lab=#net7}
N -60 190 380 190 {
lab=#net6}
N 140 40 160 40 {
lab=#net1}
N 160 40 160 70 {
lab=#net1}
N 360 130 380 130 {
lab=VSS}
N 620 130 640 130 {
lab=VSS}
N 360 -110 380 -110 {
lab=VDD}
N 360 -160 360 -110 {
lab=VDD}
N 620 -110 640 -110 {
lab=VDD}
N 640 -160 640 -110 {
lab=VDD}
N 620 -160 640 -160 {
lab=VDD}
N 360 -10 380 -10 {
lab=#net4}
N 360 -60 360 -10 {
lab=#net4}
N 360 -60 380 -60 {
lab=#net4}
N 620 -10 640 -10 {
lab=#net5}
N 640 -60 640 -10 {
lab=#net5}
N 620 -60 640 -60 {
lab=#net5}
N 360 230 380 230 {
lab=VSS}
N 620 230 640 230 {
lab=VSS}
N -60 150 -60 190 {
lab=#net6}
N 160 150 160 160 {
lab=#net7}
N 50 -110 50 -90 {
lab=VDD}
N 30 -110 30 -60 {
lab=VDD}
N 360 230 360 270 {
lab=VSS}
N 360 270 380 270 {
lab=VSS}
N 640 230 640 270 {
lab=VSS}
N 620 270 640 270 {
lab=VSS}
N 50 0 50 40 {
lab=#net1}
N 50 -30 50 -0 {
lab=#net1}
N 50 -160 50 -110 {
lab=VDD}
N 30 -160 30 -110 {
lab=VDD}
N -50 -160 40 -160 {
lab=VDD}
N 10 350 530 350 {
lab=VBIAS_N}
N 530 230 530 350 {
lab=VBIAS_N}
N 10 320 500 320 {
lab=VCASC_N}
N 500 130 500 320 {
lab=VCASC_N}
N 110 -60 110 260 {
lab=VBIAS_P}
N 90 -60 110 -60 {
lab=VBIAS_P}
N 10 260 110 260 {
lab=VBIAS_P}
N 10 290 300 290 {
lab=VCASC_P}
N -170 210 220 210 {
lab=#net2}
N 220 120 220 210 {
lab=#net2}
N -170 120 -120 120 {
lab=VI_P}
N -170 260 10 260 {
lab=VBIAS_P}
N -170 290 10 290 {
lab=VCASC_P}
N -170 320 10 320 {
lab=VCASC_N}
N -170 350 10 350 {
lab=VBIAS_N}
N -170 -160 -50 -160 {
lab=VDD}
N 620 60 700 60 {
lab=VO}
N 360 130 360 230 {
lab=VSS}
N 640 130 640 230 {
lab=VSS}
N -170 380 620 380 {
lab=VSS}
N 620 280 620 380 {
lab=VSS}
N 380 280 380 380 {
lab=VSS}
N 300 290 470 290 {
lab=VCASC_P}
N 470 -10 470 290 {
lab=VCASC_P}
N 440 -110 440 40 {
lab=#net3}
N 380 40 440 40 {
lab=#net3}
C {sky130_fd_pr/pfet_01v8.sym} 70 -60 0 1 {name=M2A
L=20
W=8
nf=8
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
C {sky130_fd_pr/pfet_01v8.sym} -80 120 0 0 {name=M1B
L=10
W=250
nf=250
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
C {sky130_fd_pr/pfet_01v8.sym} 180 120 0 1 {name=M1A
L=10
W=250
nf=250
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
C {sky130_fd_pr/nfet_01v8.sym} 400 130 0 1 {name=M4B
L=1.5
W=20
nf=20 
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
C {sky130_fd_pr/nfet_01v8.sym} 600 130 0 0 {name=M4A
L=1.5
W=20
nf=20 
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
C {sky130_fd_pr/nfet_01v8.sym} 400 230 0 1 {name=M3B
L=30
W=5
nf=5
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
C {sky130_fd_pr/nfet_01v8.sym} 600 230 0 0 {name=M3A
L=30
W=5
nf=5
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
C {sky130_fd_pr/pfet_01v8.sym} 400 -110 0 1 {name=M5B
L=20
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
C {sky130_fd_pr/pfet_01v8.sym} 600 -110 0 0 {name=M5A
L=20
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
C {sky130_fd_pr/pfet_01v8.sym} 400 -10 0 1 {name=M6B
L=3.5
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
C {sky130_fd_pr/pfet_01v8.sym} 600 -10 0 0 {name=M6A
L=3.5
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
C {devices/ipin.sym} -170 -160 0 0 {name=p1 lab=VDD}
C {devices/ipin.sym} -170 210 0 0 {name=p2 lab=VI_N}
C {devices/ipin.sym} -170 120 0 0 {name=p3 lab=VI_P}
C {devices/ipin.sym} -170 260 0 0 {name=p6 lab=VBIAS_P}
C {devices/ipin.sym} -170 350 2 1 {name=p7 lab=VBIAS_N}
C {devices/ipin.sym} -170 320 2 1 {name=p8 lab=VCASC_N}
C {devices/ipin.sym} -170 290 2 1 {name=p5 lab=VCASC_P}
C {devices/opin.sym} 700 60 0 0 {name=p4 lab=VO}
C {devices/ipin.sym} -170 380 0 0 {name=p9 lab=VSS}
