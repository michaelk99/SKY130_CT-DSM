v {xschem version=3.4.0 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 60 50 60 90 {
lab=VSS}
N 60 20 80 20 {
lab=VSS}
N 80 20 80 70 {
lab=VSS}
N 70 70 80 70 {
lab=VSS}
N 60 70 70 70 {
lab=VSS}
N 60 -50 60 -10 {
lab=VB_N}
N 0 20 20 20 {
lab=VB_N}
N 0 -30 0 20 {
lab=VB_N}
N 0 -30 60 -30 {
lab=VB_N}
N 60 -30 90 -30 {
lab=VB_N}
N 350 -170 390 -170 {
lab=VDD}
N 370 -150 370 -140 {
lab=VSS}
N 370 -150 390 -150 {
lab=VSS}
N 690 -170 730 -170 {
lab=VBA_P}
N 690 -150 730 -150 {
lab=VBAC_P}
N 690 -130 730 -130 {
lab=VBAC_N}
N 690 -110 730 -110 {
lab=VBA_N}
N 730 -170 930 -170 {
lab=VBA_P}
N 730 -150 930 -150 {
lab=VBAC_P}
N 730 -130 930 -130 {
lab=VBAC_N}
N 730 -110 930 -110 {
lab=VBA_N}
N 720 -170 720 -70 {
lab=VBA_P}
N 780 -150 780 -70 {
lab=VBAC_P}
N 840 -130 840 -70 {
lab=VBAC_N}
N 900 -110 900 -70 {
lab=VBA_N}
N 720 -10 720 10 {
lab=VSS}
N 720 10 900 10 {
lab=VSS}
N 900 -10 900 10 {
lab=VSS}
N 840 -10 840 10 {
lab=VSS}
N 780 -10 780 10 {
lab=VSS}
N 810 10 810 20 {
lab=VSS}
N 90 -30 210 -30 {
lab=VB_N}
N 160 -30 160 10 {
lab=VB_N}
N 160 70 160 90 {
lab=VSS}
N 0 -170 350 -170 {
lab=VDD}
N 60 -170 60 -110 {
lab=VDD}
N 810 20 810 90 {
lab=VSS}
N 0 90 810 90 {
lab=VSS}
N 370 -140 370 90 {
lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 40 20 0 0 {name=M3G
L=20
W=1
nf=1
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
C {devices/isource.sym} 60 -80 0 0 {name=IMAIN1 value=320n}
C {devices/capa.sym} 720 -40 0 0 {name=C3
m=1
value=1u
footprint=1206
device="ceramic capacitor"}
C {devices/capa.sym} 780 -40 0 0 {name=C4
m=1
value=1u
footprint=1206
device="ceramic capacitor"}
C {devices/capa.sym} 840 -40 0 0 {name=C5
m=1
value=1u
footprint=1206
device="ceramic capacitor"}
C {devices/capa.sym} 900 -40 0 0 {name=C6
m=1
value=1u
footprint=1206
device="ceramic capacitor"}
C {devices/capa.sym} 160 40 0 0 {name=C7
m=1
value=1u
footprint=1206
device="ceramic capacitor"}
C {devices/ipin.sym} 0 -170 0 0 {name=p1 lab=VDD}
C {devices/ipin.sym} 0 90 0 0 {name=p2 lab=VSS}
C {devices/opin.sym} 930 -170 0 0 {name=p3 lab=VBA_P}
C {devices/opin.sym} 930 -150 0 0 {name=p4 lab=VBAC_P}
C {devices/opin.sym} 930 -130 0 0 {name=p5 lab=VBAC_N}
C {devices/opin.sym} 930 -110 0 0 {name=p6 lab=VBA_N}
C {devices/opin.sym} 210 -30 0 0 {name=p7 lab=VB_N}
C {/foss/designs/aux-amp/amp_gm_boost_bias_2.sym} 540 -140 0 0 {name=x1}
