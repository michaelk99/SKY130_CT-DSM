v {xschem version=3.4.0 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
T {Gm-Booster: gm/Id
PMOS Pair, 		M1,M2:

PMOS Tail CS, 		M5:

NMOS CS, 		M11, M12:

NMOS Casc., 		M1A, M2A:

PMOS CS, 		M3, M4:

PMOS Casc., 		M3A, M4A:} 1720 -440 0 0 0.4 0.4 {}
T {Main Diff-Pair: gm/Id
NMOS Pair, 		M1:

NMOS Tail CS, 		M3:

PMOS CS, 		M2:
} 1720 -690 0 0 0.4 0.4 {}
N 80 -750 80 -720 {
lab=GND}
N 80 -850 80 -810 {
lab=vdd}
N 1490 -330 1490 -310 {
lab=vout}
N 1250 -660 1250 -640 {
lab=voutp}
N 1250 -480 1250 -460 {
lab=voutn}
N 680 -770 840 -770 {
lab=vbias}
N 680 -790 860 -790 {
lab=#net1}
N 680 -810 880 -810 {
lab=#net2}
N 680 -830 900 -830 {
lab=#net3}
N 680 -850 920 -850 {
lab=#net4}
N 150 -750 150 -720 {
lab=GND}
N 150 -850 150 -810 {
lab=vddb}
N 350 -850 380 -850 {
lab=vddb}
N 350 -830 350 -820 {
lab=GND}
N 350 -830 380 -830 {
lab=GND}
N 1420 -510 1420 -500 {
lab=GND}
N 1400 -610 1420 -610 {
lab=vddcmfb}
N 1400 -510 1420 -510 {
lab=GND}
N 1570 -460 1570 -430 {
lab=GND}
N 1570 -560 1570 -520 {
lab=vcmo}
N 1400 -530 1420 -530 {
lab=vcmo}
N 1400 -550 1420 -550 {
lab=vbias}
N 400 -590 400 -550 {
lab=#net5}
N 400 -490 400 -450 {
lab=vcmi}
N 400 -470 500 -470 {
lab=vcmi}
N 500 -470 500 -450 {
lab=vcmi}
N 500 -390 500 -370 {
lab=GND}
N 400 -390 400 -320 {
lab=vin}
N 400 -320 600 -320 {
lab=vin}
N 400 -720 400 -650 {
lab=vip}
N 400 -720 600 -720 {
lab=vip}
N 320 -600 360 -600 {
lab=GND}
N 320 -600 320 -400 {
lab=GND}
N 320 -400 360 -400 {
lab=GND}
N 290 -440 360 -440 {
lab=#net6}
N 290 -640 290 -440 {
lab=#net6}
N 290 -640 360 -640 {
lab=#net6}
N 240 -640 240 -550 {
lab=#net6}
N 240 -640 290 -640 {
lab=#net6}
N 240 -490 240 -370 {
lab=GND}
N 240 -400 320 -400 {
lab=GND}
N 200 -500 200 -470 {
lab=GND}
N 200 -470 240 -470 {
lab=GND}
N 80 -540 80 -500 {
lab=vid}
N 80 -540 200 -540 {
lab=vid}
N 80 -440 80 -370 {
lab=GND}
N 1440 -660 1510 -660 {
lab=vcmo}
N 1510 -660 1510 -460 {
lab=vcmo}
N 1440 -460 1510 -460 {
lab=vcmo}
N 1510 -560 1570 -560 {
lab=vcmo}
N 1420 -530 1510 -530 {
lab=vcmo}
N 1240 -250 1240 -230 {
lab=GND}
N 1240 -330 1240 -310 {
lab=#net7}
N 1340 -250 1340 -230 {
lab=GND}
N 1340 -330 1340 -310 {
lab=#net8}
N 1340 -330 1400 -330 {
lab=#net8}
N 1400 -330 1400 -260 {
lab=#net8}
N 1400 -260 1450 -260 {
lab=#net8}
N 1240 -360 1240 -330 {
lab=#net7}
N 1240 -360 1450 -360 {
lab=#net7}
N 1450 -360 1450 -300 {
lab=#net7}
N 1490 -250 1490 -230 {
lab=GND}
N 840 -770 840 -670 {
lab=vbias}
N 860 -790 860 -670 {
lab=#net1}
N 880 -810 880 -670 {
lab=#net2}
N 900 -830 900 -670 {
lab=#net3}
N 920 -850 920 -670 {
lab=#net4}
N 600 -520 780 -520 {
lab=vin}
N 600 -520 600 -320 {
lab=vin}
N 600 -600 780 -600 {
lab=vip}
N 600 -720 600 -600 {
lab=vip}
N 860 -450 860 -410 {
lab=GND}
N 840 -450 840 -410 {
lab=vdd}
N 980 -560 1100 -560 {
lab=#net9}
N 980 -590 1020 -590 {
lab=voutp}
N 1020 -660 1020 -590 {
lab=voutp}
N 1020 -660 1380 -660 {
lab=voutp}
N 980 -530 1020 -530 {
lab=voutn}
N 1020 -530 1020 -460 {
lab=voutn}
N 1020 -460 1380 -460 {
lab=voutn}
N 220 -750 220 -720 {
lab=GND}
N 220 -850 220 -810 {
lab=vddcmfb}
C {devices/vsource.sym} 80 -780 0 0 {name=V1 value=1.8
}
C {devices/gnd.sym} 80 -720 0 0 {name=l1 lab=GND}
C {devices/vsource.sym} 500 -420 0 0 {name=V2 value=0.25
}
C {devices/vcvs.sym} 400 -420 0 0 {name=E1 value=0.5}
C {devices/vcvs.sym} 400 -620 0 0 {name=E2 value=0.5}
C {devices/vsource.sym} 80 -470 0 0 {name=VIN value="0 AC 1"
}
C {devices/lab_pin.sym} 400 -720 0 0 {name=l1 sig_type=std_logic lab=vip}
C {devices/lab_pin.sym} 400 -320 0 0 {name=l1 sig_type=std_logic lab=vin
}
C {devices/lab_pin.sym} 500 -470 1 0 {name=l3 sig_type=std_logic lab=vcmi}
C {devices/launcher.sym} 180 -120 0 0 {name=h1
descr="Annotate OP"
tclcommand="set show_hidden_texts 1; xschem annotate_op"}
C {sky130_fd_pr/corner.sym} 220 -260 0 0 {name=CORNER only_toplevel=false corner=tt}
C {devices/lab_pin.sym} 80 -540 1 0 {name=l1 sig_type=std_logic lab=vid}
C {devices/lab_pin.sym} 80 -850 1 0 {name=l1 sig_type=std_logic lab=vdd}
C {devices/lab_pin.sym} 1490 -330 0 1 {name=l1 sig_type=std_logic lab=vout}
C {devices/gnd.sym} 80 -370 0 0 {name=l1 lab=GND}
C {devices/code.sym} 90 -260 0 0 {name=STIMULI
only_toplevel=false
value="
.options savecurrents
.control
save all

let f_sig = 32
let f_min = 0.1
let f_max = 128
let tper_sig = 1/f_sig
let tfr_sig = tper_sig/2
alter @VIN[SIN] = [ 0 0.01 $&f_sig 0 0 0 ]
alter @VIN[DC] = 0.0

let tstep = 0.01/f_sig
let tstop = 500/f_sig
let tstart = 2500*tstep

set fndc = /foss/designs/frontend/frontend_dc.txt
set fntran = /foss/designs/frontend/frontend_tran.txt
set fnspec = /foss/designs/frontend/frontend_spec.txt
set fnhd = /foss/designs/frontend/frontend_hd.txt
set fnnoise = /foss/designs/frontend/frontend_noise.txt
set wr_singlescale
set wr_vecnames
option numdgt=5


** Main Simulations
	alter @VINDC[DC] = 0
	dc VIN -500m 500m 31m
	ac dec 1000 0.1 1e7
	alter @VINDC[DC] = 0.25
	tran $&tstep $&tstop $&tstart
	alter @VINDC[DC] = 0
	noise v(vout) VIN dec 100 0.1 100k 1
	noise v(vout) VIN dec 10 0.1 128

	setplot noise1
	let acgain = onoise_spectrum/inoise_spectrum

	let mdiffpair_gmb_in = sqrt(4)*onoise.m.x1.x1.xm1a.msky130_fd_pr__pfet_01v8/acgain
	let mload_gmb_in = sqrt(4)*onoise.m.x1.x1.xm3a.msky130_fd_pr__nfet_01v8/acgain
	let mload_in = sqrt(2)*onoise.m.x1.xm2a.msky130_fd_pr__pfet_01v8_lvt/acgain
	let mdiffpair_in = sqrt(2)*onoise.m.x1.xm1a.msky130_fd_pr__nfet_01v8/acgain
	let mtail_in = onoise.m.x1.xm3a.msky130_fd_pr__nfet_01v8/acgain
	*let m1b_in = onoise.m.xm1b.msky130_fd_pr__nfet_01v8/acgain

	*let m2a_in = onoise.m.xm2a.msky130_fd_pr__pfet_01v8_lvt/acgain
	*let m2b_in = onoise.m.xm2b.msky130_fd_pr__pfet_01v8_lvt/acgain

	*let m3a_in = onoise.m.xm3a.msky130_fd_pr__nfet_01v8/acgain
	*let m3b_in = onoise.m.xm3b.msky130_fd_pr__nfet_01v8/acgain

	let rs_in = sqrt(onoise_r.x1.rs1^2+onoise_r.x1.rs2^2)/acgain

	*plot inoise_spectrum m1a_in m2a_in m3a_in rs_in 

	*plot m2a_in m2b_in
	plot inoise_spectrum rs_in mdiffpair_gmb_in mload_gmb_in mload_in mdiffpair_in ylog xlog
	wrdata $fnnoise inoise_spectrum rs_in mdiffpair_gmb_in mload_gmb_in mload_in mdiffpair_in
	
	setplot ac1
	let A = v(vout)/v(vin)
	plot vdb(A) 180/PI*phase(A)
	
	setplot dc1
	let vid = v(vid)	
	let iod = (viop#branch-vion#branch)
	let gm  = abs(iod/vid)
	plot iod
	plot gm 0
	wrdata $fndc iod gm

	setplot tran1
	let vid = v(vid)
	let iod = (viop#branch-vion#branch)

	meas tran iod_max max iod
	meas tran vid_max max vid
	let gm = iod_max/vid_max
	plot iod

	*plot gm
	wrdata $fntran iod

	** FFT
	
	linearize iod
	set specwindow=hanning
	fft iod
	setplot sp2

	let N = length(iod)
	let fres = frequency[n-1]/n
	let fmin_idx = ceil(const.f_min/fres)
	let fmax_idx = ceil(const.f_max/fres)

	let iod_spec = mag(iod)
	let iod_spec_slice = iod_spec[fmin_idx,fmax_idx]
	let freq = frequency[fmin_idx,fmax_idx]
	meas sp iod_max max iod_spec_slice
	let iod_spec_db = 20*log10(iod_spec_slice/iod_max)
	plot iod_spec_db vs freq
	
	** Calc HD2, HD3
	let sig_idx = ceil(const.f_sig/fres)
	let hd2_idx = 2*sig_idx
	let hd3_idx = 3*sig_idx
	let sig_pwr = iod_spec[sig_idx-1]^2+iod_spec[sig_idx]^2+iod_spec[sig_idx+1]^2
	let hd2_pwr = iod_spec[hd2_idx-1]^2+iod_spec[hd2_idx]^2+iod_spec[hd2_idx+1]^2
	let hd3_pwr = iod_spec[hd3_idx-1]^2+iod_spec[hd3_idx]^2+iod_spec[hd3_idx+1]^2
	let hd2 = sqrt(hd2_pwr/sig_pwr)
	let hd3 = sqrt(hd3_pwr/sig_pwr)
	let hd2_dB = 20*log10(hd2)
	let hd3_dB = 20*log10(hd3)
	setscale freq
	wrdata $fnspec iod_spec_db 
	*wrdata $fnhd hd3[0] hd3_db[0] hd2[0] hd2_db[0] fres n

alter @VIN[DC] = 0
op
let gmId1 = @m.x1.x1.xm1a.msky130_fd_pr__pfet_01v8[gm]/@m.x1.x1.xm1a.msky130_fd_pr__pfet_01v8[id]
let gmId5 = @m.x1.x1.xm2a.msky130_fd_pr__pfet_01v8[gm]/@m.x1.x1.xm2a.msky130_fd_pr__pfet_01v8[id]
let gmId11 = @m.x1.x1.xm3a.msky130_fd_pr__nfet_01v8[gm]/@m.x1.x1.xm3a.msky130_fd_pr__nfet_01v8[id]
let gmId1a = @m.x1.x1.xm4a.msky130_fd_pr__nfet_01v8[gm]/@m.x1.x1.xm4a.msky130_fd_pr__nfet_01v8[id]
let gmId3 = @m.x1.x1.xm5a.msky130_fd_pr__pfet_01v8[gm]/@m.x1.x1.xm5a.msky130_fd_pr__pfet_01v8[id]
let gmId3a = @m.x1.x1.xm5a.msky130_fd_pr__pfet_01v8[gm]/@m.x1.x1.xm6a.msky130_fd_pr__pfet_01v8[id]

let gmId1_main = @m.x1.xm1a.msky130_fd_pr__nfet_01v8[gm]/@m.x1.xm1a.msky130_fd_pr__nfet_01v8[id]
let gmId_tail = @m.x1.xm3a.msky130_fd_pr__nfet_01v8[gm]/@m.x1.xm3a.msky130_fd_pr__nfet_01v8[id]
let gmId_load = @m.x1.xm2a.msky130_fd_pr__pfet_01v8_lvt[gm]/@m.x1.xm2a.msky130_fd_pr__pfet_01v8_lvt[id]
remzerovec
write frontend_tb_dc.raw
.endc"}
C {devices/vsource.sym} 400 -520 0 0 {name=VINDC value=0.25
}
C {/foss/designs/frontend/frontend_cmfb.sym} 1250 -560 0 0 {name=x2}
C {/foss/designs/frontend/frontend_bias.sym} 530 -810 0 0 {name=x3}
C {devices/vsource.sym} 150 -780 0 0 {name=V3 value=1.8
}
C {devices/gnd.sym} 150 -720 0 0 {name=l2 lab=GND}
C {devices/lab_pin.sym} 150 -850 1 0 {name=l4 sig_type=std_logic lab=vddb}
C {devices/lab_pin.sym} 350 -850 0 0 {name=l5 sig_type=std_logic lab=vddb}
C {devices/lab_pin.sym} 840 -410 3 0 {name=l6 sig_type=std_logic lab=vdd}
C {devices/gnd.sym} 350 -820 0 0 {name=l7 lab=GND}
C {devices/gnd.sym} 860 -410 0 0 {name=l8 lab=GND}
C {devices/gnd.sym} 1420 -500 0 0 {name=l9 lab=GND}
C {devices/vsource.sym} 1570 -490 0 0 {name=V4 value=0.9
}
C {devices/gnd.sym} 1570 -430 0 0 {name=l11 lab=GND}
C {devices/lab_pin.sym} 1570 -560 0 1 {name=l12 sig_type=std_logic lab=vcmo}
C {devices/lab_pin.sym} 710 -770 3 0 {name=p1 sig_type=std_logic lab=vbias}
C {devices/lab_pin.sym} 1420 -550 2 0 {name=p2 sig_type=std_logic lab=vbias}
C {devices/gnd.sym} 500 -370 0 0 {name=l14 lab=GND}
C {devices/vcvs.sym} 240 -520 0 0 {name=E3 value=1}
C {devices/gnd.sym} 240 -370 0 0 {name=l15 lab=GND}
C {devices/lab_pin.sym} 1250 -660 1 0 {name=l16 sig_type=std_logic lab=voutp
}
C {devices/lab_pin.sym} 1250 -460 1 1 {name=l17 sig_type=std_logic lab=voutn
}
C {devices/vsource.sym} 1410 -660 3 0 {name=VIOP value=0
}
C {devices/vsource.sym} 1410 -460 3 0 {name=VION value=0
}
C {devices/gnd.sym} 1240 -230 0 0 {name=l13 lab=GND}
C {devices/ccvs.sym} 1240 -280 0 0 {name=H3 vnam=viop value=0.5}
C {devices/gnd.sym} 1340 -230 0 0 {name=l19 lab=GND}
C {devices/ccvs.sym} 1340 -280 0 0 {name=H4 vnam=vion value=0.5}
C {devices/vcvs.sym} 1490 -280 0 0 {name=E4 value=1}
C {devices/gnd.sym} 1490 -230 0 0 {name=l18 lab=GND}
C {/foss/designs/frontend/frontend_main.sym} 800 -560 0 0 {name=x1}
C {devices/vsource.sym} 220 -780 0 0 {name=V5 value=1.8
}
C {devices/gnd.sym} 220 -720 0 0 {name=l20 lab=GND}
C {devices/lab_pin.sym} 220 -850 1 0 {name=l21 sig_type=std_logic lab=vddcmfb}
C {devices/lab_pin.sym} 1420 -610 2 0 {name=l10 sig_type=std_logic lab=vddcmfb}
C {devices/ngspice_get_expr.sym} 2040 -250 0 0 {name=r6 node="[format %.3g [expr [ngspice::get_node \\\{gmId1a\\\}] ]]"
descr="gm_Id"}
C {devices/ngspice_get_expr.sym} 2040 -390 0 0 {name=r3 node="[format %.3g [expr [ngspice::get_node \\\{gmId1\\\}] ]]"
descr="gm_Id"}
C {devices/ngspice_get_expr.sym} 2040 -300 0 0 {name=r1 node="[format %.3g [expr [ngspice::get_node \\\{gmId11\\\}] ]]"
descr="gm_Id"}
C {devices/ngspice_get_expr.sym} 2040 -350 0 0 {name=r7 node="[format %.3g [expr [ngspice::get_node \\\{gmId5\\\}] ]]"
descr="gm_Id"}
C {devices/ngspice_get_expr.sym} 2040 -200 0 0 {name=r2 node="[format %.3g [expr [ngspice::get_node \\\{gmId3\\\}] ]]"
descr="gm_Id"}
C {devices/ngspice_get_expr.sym} 2040 -150 0 0 {name=r4 node="[format %.3g [expr [ngspice::get_node \\\{gmId3a\\\}] ]]"
descr="gm_Id"}
C {devices/ngspice_get_expr.sym} 1970 -640 0 0 {name=r5 node="[format %.3g [expr [ngspice::get_node \\\{gmId1_main\\\}] ]]"
descr="gm_Id"}
C {devices/ngspice_get_expr.sym} 1970 -550 0 0 {name=r8 node="[format %.3g [expr [ngspice::get_node \\\{gmId_load\\\}] ]]"
descr="gm_Id"}
C {devices/ngspice_get_expr.sym} 1970 -600 0 0 {name=r9 node="[format %.3g [expr [ngspice::get_node \\\{gmId_tail\\\}] ]]"
descr="gm_Id"}
C {devices/title.sym} 160 -40 0 0 {name=l22 author="Michael Koefinger"}
