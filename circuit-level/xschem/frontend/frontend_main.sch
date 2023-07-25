v {xschem version=3.4.0 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -110 30 -110 70 {
lab=VO_N}
N 110 30 110 70 {
lab=VO_P}
N -110 130 -110 170 {
lab=#net1}
N 110 130 110 170 {
lab=#net2}
N -110 100 -80 100 {
lab=VSS}
N 80 100 110 100 {
lab=VSS}
N 0 360 0 400 {
lab=VSS}
N 40 310 60 310 {
lab=VB_N}
N -20 310 0 310 {
lab=VSS}
N -20 310 -20 360 {
lab=VSS}
N 0 340 0 360 {
lab=VSS}
N -110 -200 -110 -160 {
lab=VDD}
N 110 -200 110 -160 {
lab=VDD}
N -130 -180 -130 -130 {
lab=VDD}
N -130 -180 -110 -180 {
lab=VDD}
N 130 -180 130 -130 {
lab=VDD}
N 110 -180 130 -180 {
lab=VDD}
N -130 -130 -110 -130 {
lab=VDD}
N 110 -130 130 -130 {
lab=VDD}
N -20 360 0 360 {
lab=VSS}
N -70 -130 -40 -130 {
lab=VCMFB}
N 40 -130 70 -130 {
lab=VCMFB}
N -80 100 80 100 {
lab=VSS}
N -370 200 -370 230 {
lab=VSS}
N 370 200 370 230 {
lab=VSS}
N 150 100 260 100 {
lab=#net3}
N -260 100 -150 100 {
lab=#net4}
N -540 70 -480 70 {
lab=VI_P}
N 480 70 560 70 {
lab=VI_N}
N 110 230 220 230 {
lab=#net2}
N 220 260 520 260 {
lab=#net2}
N 520 130 520 260 {
lab=#net2}
N 480 130 520 130 {
lab=#net2}
N -520 130 -480 130 {
lab=#net1}
N -520 130 -520 260 {
lab=#net1}
N -520 260 -220 260 {
lab=#net1}
N -220 230 -110 230 {
lab=#net1}
N 410 -30 410 -0 {
lab=VDD}
N -140 30 -110 30 {
lab=VO_N}
N -220 30 -200 30 {
lab=#net4}
N -220 30 -220 100 {
lab=#net4}
N 110 30 150 30 {
lab=VO_P}
N 210 30 230 30 {
lab=#net3}
N 230 30 230 100 {
lab=#net3}
N -40 -130 40 -130 {
lab=VCMFB}
N 0 230 0 280 {
lab=#net5}
N -30 230 0 230 {
lab=#net5}
N 0 230 30 230 {
lab=#net5}
N -110 230 -90 230 {
lab=#net1}
N 90 230 110 230 {
lab=#net2}
N -110 170 -110 230 {
lab=#net1}
N 110 170 110 230 {
lab=#net2}
N 220 230 220 260 {
lab=#net2}
N -220 230 -220 260 {
lab=#net1}
N 410 -200 410 -30 {
lab=VDD}
N -680 -200 410 -200 {
lab=VDD}
N -20 100 -20 310 {
lab=VSS}
N 0 400 0 520 {
lab=VSS}
N -680 520 -0 520 {
lab=VSS}
N -370 230 -370 520 {
lab=VSS}
N 370 230 370 520 {
lab=VSS}
N 0 520 370 520 {
lab=VSS}
N -680 -20 -390 -20 {
lab=VBA_P}
N -410 -200 -410 0 {
lab=VDD}
N -680 -40 -370 -40 {
lab=VBAC_P}
N -680 -60 -350 -60 {
lab=VBAC_N}
N -680 -80 -330 -80 {
lab=VBA_N}
N -110 -100 -110 30 {
lab=VO_N}
N 110 -100 110 30 {
lab=VO_P}
N -390 -20 -390 -0 {
lab=VBA_P}
N -370 -40 -370 0 {
lab=VBAC_P}
N -350 -60 -350 0 {
lab=VBAC_N}
N -330 -80 -330 0 {
lab=VBA_N}
N -390 -20 390 -20 {
lab=VBA_P}
N 390 -20 390 -0 {
lab=VBA_P}
N -370 -40 370 -40 {
lab=VBAC_P}
N 370 -40 370 -0 {
lab=VBAC_P}
N -350 -60 350 -60 {
lab=VBAC_N}
N 350 -60 350 -0 {
lab=VBAC_N}
N -330 -80 330 -80 {
lab=VBA_N}
N 330 -80 330 0 {
lab=VBA_N}
N -680 70 -540 70 {
lab=VI_P}
N 60 310 60 460 {
lab=VB_N}
N -680 460 60 460 {
lab=VB_N}
C {sky130_fd_pr/nfet_01v8.sym} 20 310 0 1 {name=M3A
L=20
W=30
nf=15
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
C {sky130_fd_pr/nfet_01v8.sym} -130 100 0 0 {name=M1A
L=1.5
W=10
nf=10
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
C {sky130_fd_pr/nfet_01v8.sym} 130 100 0 1 {name=M1B
L=1.5
W=10
nf=10
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
C {sky130_fd_pr/pfet_01v8_lvt.sym} -90 -130 0 1 {name=M2A
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
model=pfet_01v8_lvt
spiceprefix=X
}
C {sky130_fd_pr/pfet_01v8_lvt.sym} 90 -130 0 0 {name=M2B
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
model=pfet_01v8_lvt
spiceprefix=X
}
C {devices/res.sym} -60 230 3 0 {name=RS2
value=50k
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -170 30 3 0 {name=C1
m=1
value=3p
footprint=1206
device="ceramic capacitor"}
C {devices/capa.sym} 180 30 1 1 {name=C2
m=1
value=3p
footprint=1206
device="ceramic capacitor"}
C {devices/res.sym} 60 230 1 1 {name=RS1
value=50k
footprint=1206
device=resistor
m=1}
C {devices/ipin.sym} -680 -200 0 0 {name=p11 lab=VDD}
C {devices/ipin.sym} -680 520 0 0 {name=p12 lab=VSS}
C {devices/ipin.sym} -680 -20 0 0 {name=p13 lab=VBA_P}
C {devices/ipin.sym} -680 -40 0 0 {name=p14 lab=VBAC_P}
C {devices/ipin.sym} -680 -60 0 0 {name=p15 lab=VBAC_N}
C {devices/ipin.sym} -680 -80 0 0 {name=p16 lab=VBA_N}
C {devices/ipin.sym} -680 70 0 0 {name=p3 lab=VI_P}
C {devices/ipin.sym} 560 70 2 0 {name=p4 lab=VI_N}
C {devices/ipin.sym} -680 460 0 0 {name=p5 lab=VB_N}
C {devices/ipin.sym} 0 -130 1 0 {name=p1 lab=VCMFB}
C {devices/opin.sym} -110 30 0 0 {name=p2 lab=VO_N}
C {devices/opin.sym} 110 30 0 1 {name=p6 lab=VO_P}
C {/foss/designs/aux-amp/amp_gm_boost_2.sym} -330 100 0 0 {name=x1}
C {/foss/designs/aux-amp/amp_gm_boost_2.sym} 330 100 0 1 {name=x2}
