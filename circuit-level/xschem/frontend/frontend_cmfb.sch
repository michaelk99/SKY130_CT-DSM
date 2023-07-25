v {xschem version=3.1.0 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 350 30 350 50 {
lab=#net1}
N 350 50 510 50 {
lab=#net1}
N 510 30 510 50 {
lab=#net1}
N 630 30 630 50 {
lab=#net2}
N 630 50 790 50 {
lab=#net2}
N 790 30 790 50 {
lab=#net2}
N 430 50 430 70 {
lab=#net1}
N 710 50 710 70 {
lab=#net2}
N 470 100 670 100 {
lab=VBIAS}
N 550 0 590 0 {
lab=VCM}
N 510 -60 510 -30 {
lab=VFB}
N 510 -60 630 -60 {
lab=VFB}
N 630 -60 630 -30 {
lab=VFB}
N 600 -90 600 -60 {
lab=VFB}
N 350 0 510 0 {
lab=VSS}
N 630 0 790 0 {
lab=VSS}
N 350 -170 350 -30 {
lab=VDD}
N 350 -170 790 -170 {
lab=VDD}
N 790 -170 790 -30 {
lab=VDD}
N 600 -120 620 -120 {
lab=VDD}
N 540 -120 560 -120 {
lab=VFB}
N 540 -120 540 -80 {
lab=VFB}
N 540 -80 540 -60 {
lab=VFB}
N 600 -160 600 -150 {
lab=VDD}
N 270 0 310 0 {
lab=#net3}
N 710 130 710 150 {
lab=VSS}
N 430 130 430 150 {
lab=VSS}
N 410 140 430 140 {
lab=VSS}
N 410 0 410 140 {
lab=VSS}
N 410 100 430 100 {
lab=VSS}
N 710 140 730 140 {
lab=VSS}
N 730 0 730 140 {
lab=VSS}
N 710 100 730 100 {
lab=VSS}
N 600 -170 600 -160 {
lab=VDD}
N 620 -170 620 -120 {
lab=VDD}
N 40 -120 540 -120 {
lab=VFB}
N 40 -160 350 -160 {
lab=VDD}
N 40 200 580 200 {
lab=VCM}
N 580 0 580 200 {
lab=VCM}
N 710 150 710 240 {
lab=VSS}
N 40 240 710 240 {
lab=VSS}
N 430 150 430 240 {
lab=VSS}
N 40 160 540 160 {
lab=VBIAS}
N 540 100 540 160 {
lab=VBIAS}
N 40 -40 860 -40 {
lab=VO_P}
N 830 -0 860 -0 {
lab=VO_P}
N 860 -40 860 -0 {
lab=VO_P}
N 40 -0 270 0 {}
C {sky130_fd_pr/nfet_01v8.sym} 450 100 0 1 {name=M1
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
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 690 100 0 0 {name=M2
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
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 330 0 0 0 {name=M3
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
C {sky130_fd_pr/nfet_01v8.sym} 530 0 0 1 {name=M4
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
C {sky130_fd_pr/nfet_01v8.sym} 610 0 0 0 {name=M5
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
C {sky130_fd_pr/nfet_01v8.sym} 810 0 0 1 {name=M6
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
C {sky130_fd_pr/pfet_01v8.sym} 580 -120 0 0 {name=M7
L=80
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
C {devices/ipin.sym} 40 -40 0 0 {name=p1 lab=VO_P}
C {devices/ipin.sym} 40 0 0 0 {name=p2 lab=VO_N}
C {devices/ipin.sym} 40 -160 0 0 {name=p3 lab=VDD}
C {devices/ipin.sym} 40 240 0 0 {name=p4 lab=VSS}
C {devices/ipin.sym} 40 160 0 0 {name=p5 lab=VBIAS}
C {devices/opin.sym} 40 -120 0 1 {name=p6 lab=VFB}
C {devices/ipin.sym} 40 200 0 0 {name=p7 lab=VCM}
