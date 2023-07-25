v {xschem version=3.4.0 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -1200 40 -1200 70 {
lab=GND}
N -1200 -60 -1200 -20 {
lab=vdd}
N -160 470 -160 490 {
lab=vout}
N -30 130 -30 150 {
lab=#net1}
N -30 310 -30 330 {
lab=#net2}
N -600 20 -440 20 {
lab=vbias}
N -600 0 -420 0 {
lab=#net3}
N -600 -20 -400 -20 {
lab=#net4}
N -600 -40 -380 -40 {
lab=#net5}
N -600 -60 -360 -60 {
lab=#net6}
N -1130 40 -1130 70 {
lab=GND}
N -1130 -60 -1130 -20 {
lab=vddb}
N -930 -60 -900 -60 {
lab=vddb}
N -930 -40 -930 -30 {
lab=GND}
N -930 -40 -900 -40 {
lab=GND}
N 140 250 140 260 {
lab=GND}
N 120 250 140 250 {
lab=GND}
N -1060 40 -1060 70 {
lab=GND}
N -1060 -60 -1060 -20 {
lab=vcmo}
N 120 210 140 210 {
lab=vcmo}
N -880 200 -880 240 {
lab=#net7}
N -880 300 -880 340 {
lab=vcmi}
N -880 320 -780 320 {
lab=vcmi}
N -780 320 -780 340 {
lab=vcmi}
N -780 400 -780 420 {
lab=GND}
N -880 400 -880 470 {
lab=vin}
N -880 470 -680 470 {
lab=vin}
N -880 70 -880 140 {
lab=vip}
N -880 70 -680 70 {
lab=vip}
N -960 190 -920 190 {
lab=GND}
N -960 190 -960 390 {
lab=GND}
N -960 390 -920 390 {
lab=GND}
N -990 350 -920 350 {
lab=#net8}
N -990 150 -990 350 {
lab=#net8}
N -990 150 -920 150 {
lab=#net8}
N -1040 150 -1040 240 {
lab=#net8}
N -1040 150 -990 150 {
lab=#net8}
N -1040 300 -1040 420 {
lab=GND}
N -1040 390 -960 390 {
lab=GND}
N -1080 290 -1080 320 {
lab=GND}
N -1080 320 -1040 320 {
lab=GND}
N -1200 250 -1200 290 {
lab=vid}
N -1200 250 -1080 250 {
lab=vid}
N -1200 350 -1200 420 {
lab=GND}
N 160 130 230 130 {
lab=voutp}
N 160 330 230 330 {
lab=voutn}
N -410 550 -410 570 {
lab=GND}
N -410 470 -410 490 {
lab=#net9}
N -310 550 -310 570 {
lab=GND}
N -310 470 -310 490 {
lab=#net10}
N -310 470 -250 470 {
lab=#net10}
N -250 470 -250 540 {
lab=#net10}
N -250 540 -200 540 {
lab=#net10}
N -410 440 -410 470 {
lab=#net9}
N -410 440 -200 440 {
lab=#net9}
N -200 440 -200 500 {
lab=#net9}
N -160 550 -160 570 {
lab=GND}
N 390 170 390 300 {
lab=vcmo}
N 340 300 390 300 {
lab=vcmo}
N 390 230 420 230 {
lab=vcmo}
N 260 300 280 300 {
lab=voutn}
N 190 100 190 130 {
lab=voutp}
N 190 330 190 360 {
lab=voutn}
N 190 10 190 40 {
lab=GND}
N 190 420 190 450 {
lab=GND}
N -30 150 -30 170 {
lab=#net1}
N -30 290 -30 310 {
lab=#net2}
N -440 20 -440 120 {
lab=vbias}
N -420 0 -420 120 {
lab=#net3}
N -400 -20 -400 120 {
lab=#net4}
N -380 -40 -380 120 {
lab=#net5}
N -360 -60 -360 120 {
lab=#net6}
N -440 340 -440 360 {
lab=vdd}
N -420 340 -420 360 {
lab=GND}
N -300 230 -180 230 {
lab=#net11}
N -300 200 -260 200 {
lab=#net1}
N -260 130 -260 200 {
lab=#net1}
N -260 130 100 130 {
lab=#net1}
N -300 260 -260 260 {
lab=#net2}
N -260 260 -260 330 {
lab=#net2}
N -260 330 100 330 {
lab=#net2}
N -680 270 -680 470 {
lab=vin}
N -680 270 -500 270 {
lab=vin}
N -680 70 -680 190 {
lab=vip}
N -680 190 -500 190 {
lab=vip}
N -130 290 -130 310 {
lab=vcm_act}
N -160 310 -130 310 {
lab=vcm_act}
N 230 130 260 130 {
lab=voutp}
N 230 330 260 330 {
lab=voutn}
N 260 300 260 330 {
lab=voutn}
N 260 130 260 160 {
lab=voutp}
N 260 160 280 160 {
lab=voutp}
N 340 160 390 160 {
lab=vcmo}
N 390 160 390 170 {
lab=vcmo}
C {devices/vsource.sym} -1200 10 0 0 {name=V1 value=1.8
}
C {devices/gnd.sym} -1200 70 0 0 {name=l1 lab=GND}
C {devices/vsource.sym} -780 370 0 0 {name=V2 value=0.25
}
C {devices/vcvs.sym} -880 370 0 0 {name=E1 value=0.5}
C {devices/vcvs.sym} -880 170 0 0 {name=E2 value=0.5}
C {devices/vsource.sym} -1200 320 0 0 {name=VIN value="0 AC 1"
}
C {devices/lab_pin.sym} -880 70 0 0 {name=l1 sig_type=std_logic lab=vip}
C {devices/lab_pin.sym} -880 470 0 0 {name=l1 sig_type=std_logic lab=vin
}
C {devices/lab_pin.sym} -780 320 1 0 {name=l3 sig_type=std_logic lab=vcmi}
C {devices/launcher.sym} -1100 670 0 0 {name=h1
descr="Annotate OP"
tclcommand="set show_hidden_texts 1; xschem annotate_op"}
C {sky130_fd_pr/corner.sym} -1060 530 0 0 {name=CORNER only_toplevel=false corner=tt}
C {devices/lab_pin.sym} -1200 250 1 0 {name=l1 sig_type=std_logic lab=vid}
C {devices/lab_pin.sym} -1200 -60 0 0 {name=l1 sig_type=std_logic lab=vdd}
C {devices/lab_pin.sym} -160 470 0 1 {name=l1 sig_type=std_logic lab=vout}
C {devices/gnd.sym} -1200 420 0 0 {name=l1 lab=GND}
C {devices/code.sym} -1190 530 0 0 {name=STIMULI
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

set fnac = /foss/designs/frontend/frontend_int_ac.txt
set fntran = /foss/designs/frontend/frontend_int_tran.txt
set fnspec = /foss/designs/frontend/frontend_int_spec.txt
set fnhd = /foss/designs/frontend/frontend_int_hd.txt
set wr_singlescale
set wr_vecnames
option numdgt=5


** Main Simulations
	alter @VINDC[DC] = 0
	*dc VIN -500m 500m 31m
	ac dec 1000 0.1 1e7
	*alter @VINDC[DC] = 0.25
	tran $&tstep $&tstop $&tstart
	alter @VINDC[DC] = 0
	*noise v(vout) VIN dec 100 0.1 100k 1
	*noise v(vout) VIN dec 10 0.1 128

	*setplot noise1
	*let acgain = onoise_spectrum/inoise_spectrum

	*let m1a_in = onoise.m.xm1a.msky130_fd_pr__nfet_01v8/acgain
	*let m1b_in = onoise.m.xm1b.msky130_fd_pr__nfet_01v8/acgain

	*let m2a_in = onoise.m.xm2a.msky130_fd_pr__pfet_01v8_lvt/acgain
	*let m2b_in = onoise.m.xm2b.msky130_fd_pr__pfet_01v8_lvt/acgain

	*let m3a_in = onoise.m.xm3a.msky130_fd_pr__nfet_01v8/acgain
	*let m3b_in = onoise.m.xm3b.msky130_fd_pr__nfet_01v8/acgain

	*let rs_in = sqrt(onoise_rs1^2+onoise_rs2^2)/acgain

	*plot inoise_spectrum m1a_in m2a_in m3a_in rs_in

	*plot m2a_in m2b_in
	
	setplot ac1
	let vc = v(voutp)-v(voutn)
	let iod = (viop#branch-vion#branch)
	let ioc = @c1[i]
	let A = v(vc)/v(vin)
	let Gm = iod/v(vin)
	let Gm_c = ioc/v(vin)
	plot vdb(A) 180/PI*cphase(A)
	plot vdb(Gm)

	setplot tran1
	let vid = v(vid)
	let iod = (viop#branch-vion#branch)
	let vc = v(voutp)-v(voutn)
	let ioc = @c1[i]
	meas tran iod_max max iod
	meas tran ioc_max max ioc
	meas tran vid_max max vid
	let gm = iod_max/vid_max
	let gm_c = ioc_max/vid_max
	plot vid vc
	plot iod ioc
	

	plot gm gm_c
	wrdata $fntran iod

	** FFT
	
	linearize vc
	set specwindow=hanning
	fft vc
	setplot sp2

	let N = length(vc)
	let fres = frequency[n-1]/n
	let fmin_idx = ceil(const.f_min/fres)
	let fmax_idx = ceil(const.f_max/fres)

	let iod_spec = mag(vc)
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
remzerovec
write frontend_tb_dc.raw
.endc"}
C {devices/vsource.sym} -880 270 0 0 {name=VINDC value=0.25
}
C {/foss/designs/frontend/frontend_bias.sym} -750 -20 0 0 {name=x3}
C {devices/vsource.sym} -1130 10 0 0 {name=V3 value=1.8
}
C {devices/gnd.sym} -1130 70 0 0 {name=l2 lab=GND}
C {devices/lab_pin.sym} -1130 -60 0 0 {name=l4 sig_type=std_logic lab=vddb}
C {devices/lab_pin.sym} -930 -60 0 0 {name=l5 sig_type=std_logic lab=vddb}
C {devices/lab_pin.sym} -440 360 3 0 {name=l6 sig_type=std_logic lab=vdd}
C {devices/gnd.sym} -930 -30 0 0 {name=l7 lab=GND}
C {devices/gnd.sym} -420 360 0 0 {name=l8 lab=GND}
C {devices/gnd.sym} 140 260 0 0 {name=l9 lab=GND}
C {devices/vsource.sym} -1060 10 0 0 {name=V4 value=0.9
}
C {devices/gnd.sym} -1060 70 0 0 {name=l11 lab=GND}
C {devices/lab_pin.sym} -1060 -60 0 0 {name=l12 sig_type=std_logic lab=vcmo}
C {devices/lab_pin.sym} -570 20 3 0 {name=p1 sig_type=std_logic lab=vbias}
C {devices/gnd.sym} -780 420 0 0 {name=l14 lab=GND}
C {devices/vcvs.sym} -1040 270 0 0 {name=E3 value=1}
C {devices/gnd.sym} -1040 420 0 0 {name=l15 lab=GND}
C {devices/lab_pin.sym} 230 130 1 0 {name=l16 sig_type=std_logic lab=voutp
}
C {devices/lab_pin.sym} 230 330 1 1 {name=l17 sig_type=std_logic lab=voutn
}
C {devices/vsource.sym} 130 130 3 0 {name=VIOP value=0
}
C {devices/vsource.sym} 130 330 3 0 {name=VION value=0
}
C {devices/gnd.sym} -410 570 0 0 {name=l13 lab=GND}
C {devices/ccvs.sym} -410 520 0 0 {name=H3 vnam=viop value=0.5}
C {devices/gnd.sym} -310 570 0 0 {name=l19 lab=GND}
C {devices/ccvs.sym} -310 520 0 0 {name=H4 vnam=vion value=0.5}
C {devices/vcvs.sym} -160 520 0 0 {name=E4 value=1}
C {devices/gnd.sym} -160 570 0 0 {name=l18 lab=GND}
C {devices/lab_pin.sym} 140 210 0 1 {name=l20 sig_type=std_logic lab=vcmo}
C {devices/capa.sym} 190 390 0 0 {name=C1
m=1
value=70p
footprint=1206
device="ceramic capacitor"}
C {devices/res.sym} 310 160 3 0 {name=R1
value=2.33Meg
footprint=1206
device=resistor
m=1}
C {devices/res.sym} 310 300 3 0 {name=R2
value=2.33Meg
footprint=1206
device=resistor
m=1}
C {devices/lab_pin.sym} 420 230 0 1 {name=l21 sig_type=std_logic lab=vcmo}
C {devices/capa.sym} 190 70 2 0 {name=C4
m=1
value=70p
footprint=1206
device="ceramic capacitor"}
C {devices/gnd.sym} 190 450 0 0 {name=l24 lab=GND}
C {devices/gnd.sym} 190 10 2 0 {name=l25 lab=GND}
C {/foss/designs/frontend/frontend_main.sym} -480 230 0 0 {name=x1}
C {/foss/designs/frontend/frontend_cmfb_ideal.sym} -30 230 0 0 {name=x2 ACM=-10}
C {devices/lab_pin.sym} -160 310 0 0 {name=p2 sig_type=std_logic lab=vcm_act}
