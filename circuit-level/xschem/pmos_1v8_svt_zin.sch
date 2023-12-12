v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
T {M1-PMOS-svt} 60 190 0 0 0.4 0.4 {}
T {PMOS Input Impedance Testbench} -260 -200 0 0 0.4 0.4 {}
T {Model Zin as Cgs} 270 0 0 0 0.4 0.4 {}
T {24GOhm@100kHz} -330 10 0 0 0.4 0.4 {}
T {95MOhm@100kHz} 270 40 0 0 0.4 0.4 {}
N -700 210 -700 240 {
lab=GND}
N -570 70 -570 120 {
lab=vcmi}
N -570 120 -500 120 {
lab=vcmi}
N -500 120 -500 150 {
lab=vcmi}
N -500 210 -500 240 {
lab=GND}
N -570 -10 -570 10 {
lab=vip}
N -590 -10 -570 -10 {
lab=vip}
N -530 20 -500 20 {
lab=vid}
N -530 60 -530 80 {
lab=GND}
N -530 80 -500 80 {
lab=GND}
N -500 80 -500 90 {
lab=GND}
N -700 100 -700 150 {
lab=vdd}
N -290 110 -260 110 {
lab=vip}
N -200 110 -180 110 {
lab=vrin1}
N -120 110 -100 110 {
lab=vrin2}
N -60 110 -40 110 {
lab=vsource_m1}
N -40 60 -40 110 {
lab=vsource_m1}
N -60 60 -40 60 {
lab=vsource_m1}
N -60 60 -60 80 {
lab=vsource_m1}
N -60 40 -60 60 {
lab=vsource_m1}
N -60 140 -60 160 {
lab=vdrain_m1}
N -60 220 -60 240 {
lab=GND}
N -60 -50 -60 -20 {
lab=#net1}
N -60 -130 -60 -110 {
lab=vdd}
N -40 60 0 60 {
lab=vsource_m1}
N -60 150 0 150 {
lab=vdrain_m1}
N -190 110 -190 160 {
lab=vrin1}
N -110 110 -110 160 {
lab=vrin2}
N 310 150 330 150 {
lab=#net2}
N 430 230 430 250 {
lab=GND}
N 390 150 490 150 {
lab=vrin22}
N 430 150 430 170 {
lab=vrin22}
N 220 150 250 150 {
lab=vid}
C {devices/vsource.sym} -700 180 0 0 {name=V1 value=1.8
}
C {devices/gnd.sym} -700 240 0 0 {name=l1 lab=GND}
C {devices/vsource.sym} -500 180 0 0 {name=V2 value=0.25
}
C {devices/vcvs.sym} -570 40 0 1 {name=E2 value=1}
C {devices/vsource.sym} -500 50 0 0 {name=VIN value="0 AC 1"
}
C {devices/gnd.sym} -500 240 0 0 {name=l1 lab=GND}
C {devices/lab_pin.sym} -590 -10 0 0 {name=l1 sig_type=std_logic lab=vip}
C {devices/lab_pin.sym} -570 120 0 0 {name=l5 sig_type=std_logic lab=vcmi}
C {devices/launcher.sym} -270 440 0 0 {name=h1
descr="Annotate OP"
tclcommand="set show_hidden_texts 1; xschem annotate_op"}
C {sky130_fd_pr/corner.sym} -210 290 0 0 {name=CORNER only_toplevel=false corner=tt}
C {devices/lab_pin.sym} -500 20 1 0 {name=l1 sig_type=std_logic lab=vid}
C {devices/lab_pin.sym} -700 100 0 0 {name=l1 sig_type=std_logic lab=vdd}
C {devices/gnd.sym} -500 90 0 0 {name=l1 lab=GND}
C {devices/code.sym} -340 290 0 0 {name=STIMULI
only_toplevel=false
value="
.options savecurrents
.control
save all

save @m.xm1.msky130_fd_pr__pfet_01v8[id]
save @m.xm1.msky130_fd_pr__pfet_01v8[vth]
save @m.xm1.msky130_fd_pr__pfet_01v8[vgs]
save @m.xm1.msky130_fd_pr__pfet_01v8[vds]
save @m.xm1.msky130_fd_pr__pfet_01v8[vdsat]
save @m.xm1.msky130_fd_pr__pfet_01v8[gm]
save @m.xm1.msky130_fd_pr__pfet_01v8[gds]
save @m.xm1.msky130_fd_pr__pfet_01v8[cgs]
save @m.xm1.msky130_fd_pr__pfet_01v8[cgd]
save @m.xm1.msky130_fd_pr__pfet_01v8[cgg]
save @m.xm1.msky130_fd_pr__pfet_01v8[csg]

let f_sig = 128
alter @VIN[SIN] = [ 0 0.1 $&f_sig 0 0 0 ]
alter @VIN[DC] = 0.0

let tstep = 0.01/f_sig
let tstop = 100/f_sig

** Main Simulations
op

ac dec 100 0.1 1e5

** Expected Input Impedance based on Cgs
setplot op1
let cgsm1 = abs(@m.xm1.msky130_fd_pr__pfet_01v8[cgg])
let zin_est = 1/(2*pi*const.f_sig*cgsm1)
alter @rinp2[resistance] = zin_est
alter @cgs[capacitance] = cgsm1

setplot ac1
let zin_m1 = abs(v(vip)/viinp1#branch)
let zin_model = abs(v(vid)/viinp2#branch)
meas ac zin_m1_fmax find zin_m1 when frequency=f_sig
meas ac zin_model_fmax find zin_model when frequency=f_sig
plot vdb(zin_m1) vdb(zin_model)
plot zin_m1 zin_model

alter @rinp1[resistance] = zin_m1_fmax

tran $&tstep $&tstop
setplot tran1

let vrin_m1 = v(vrin1,vrin2)
let vref_m1 = (vip-0.25)/sqrt(2)

let vrin_ref = v(vid,vrin22)
let vref = vid/sqrt(2)
	
plot vrin_m1 vref_m1
plot vrin_ref vref
	
op

remzerovec
write pmos_1v8_svt_zin.raw
.endc"}
C {sky130_fd_pr/pfet_01v8.sym} -80 110 0 0 {name=M1
L=10
W=500
nf=500
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
C {devices/lab_pin.sym} -290 110 0 0 {name=l6 sig_type=std_logic lab=vip}
C {devices/res.sym} -150 110 3 0 {name=RINP1
value=0
footprint=1206
device=resistor
m=1}
C {devices/vsource.sym} -230 110 3 0 {name=VIINP1 value=0
}
C {devices/vsource.sym} -60 10 2 0 {name=Vsource value=0.8
}
C {devices/vsource.sym} -60 190 0 0 {name=Vdrain value=0.15
}
C {devices/gnd.sym} -60 240 0 0 {name=l11 lab=GND}
C {devices/lab_pin.sym} -60 -130 1 0 {name=l14 sig_type=std_logic lab=vdd}
C {devices/isource.sym} -60 -80 0 0 {name=I0 value=160n}
C {devices/lab_pin.sym} 0 60 2 0 {name=p6 sig_type=std_logic lab=vsource_m1}
C {devices/lab_pin.sym} 0 150 2 0 {name=p10 sig_type=std_logic lab=vdrain_m1}
C {devices/lab_pin.sym} -190 160 3 0 {name=p11 sig_type=std_logic lab=vrin1}
C {devices/lab_pin.sym} -110 160 3 0 {name=p12 sig_type=std_logic lab=vrin2}
C {devices/ngspice_get_value.sym} 60 260 0 0 {name=r26 node=v(@m.xm1a.msky130_fd_pr__pfet_01v8[vth])
descr="vth"}
C {devices/ngspice_get_value.sym} 120 260 0 0 {name=r27 node=v(@m.xm1.msky130_fd_pr__pfet_01v8[vgs])
descr="vgs"}
C {devices/ngspice_get_value.sym} 60 290 0 0 {name=r28 node=v(@m.xm1a.msky130_fd_pr__pfet_01v8[vds])
descr="vds"}
C {devices/ngspice_get_expr.sym} 120 290 0 0 {name=r29 node="[format %.2g [expr [ngspice::get_voltage \\\{@m.xm1a.msky130_fd_pr__pfet_01v8[vgs]\\\}] - [ngspice::get_voltage \\\{@m.xm1a.msky130_fd_pr__pfet_01v8[vth]\\\}]]]"
descr="vod"}
C {devices/ngspice_get_value.sym} 170 260 0 0 {name=r34 node=@m.xm1.msky130_fd_pr__pfet_01v8[csg]
descr="csg"}
C {devices/ngspice_get_value.sym} 170 290 0 0 {name=r30 node=@m.xm1.msky130_fd_pr__pfet_01v8[cgd]
descr="cgd"}
C {devices/res.sym} 360 150 3 0 {name=RINP2
value=0
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} 430 200 0 0 {name=Cgs
m=1
value=13p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_pin.sym} 490 150 2 0 {name=p13 sig_type=std_logic lab=vrin22}
C {devices/gnd.sym} 430 250 0 0 {name=l25 lab=GND}
C {devices/lab_pin.sym} 220 150 0 0 {name=l15 sig_type=std_logic lab=vid}
C {devices/vsource.sym} 280 150 3 0 {name=VIINP2 value=0
}
C {devices/ngspice_get_value.sym} 170 330 0 0 {name=r1 node=@m.xm1.msky130_fd_pr__pfet_01v8[cgg]
descr="cgg"}
