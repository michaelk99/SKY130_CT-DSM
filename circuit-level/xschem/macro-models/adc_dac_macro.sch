v {xschem version=3.1.0 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -410 -250 -410 -200 {
lab=vcm}
N -410 -200 -340 -200 {
lab=vcm}
N -340 -200 -340 -170 {
lab=vcm}
N -340 -200 -270 -200 {
lab=vcm}
N -270 -250 -270 -200 {
lab=vcm}
N -340 -110 -340 -80 {
lab=GND}
N -410 -330 -410 -310 {
lab=vi1_p}
N -430 -330 -410 -330 {
lab=vi1_p}
N -270 -330 -270 -310 {
lab=vi1_n}
N -270 -330 -250 -330 {
lab=vi1_n}
N -370 -300 -340 -300 {
lab=vid}
N -340 -300 -310 -300 {
lab=vid}
N -370 -260 -370 -240 {
lab=GND}
N -370 -240 -340 -240 {
lab=GND}
N -340 -240 -310 -240 {
lab=GND}
N -310 -260 -310 -240 {
lab=GND}
N -340 -240 -340 -230 {
lab=GND}
N -420 60 -420 90 {
lab=GND}
N -420 -30 -420 0 {
lab=vclk}
N -80 -270 -40 -270 {
lab=vi1_p}
N -80 -230 -40 -230 {
lab=vi1_n}
N 80 -300 140 -300 {
lab=D2}
N 0 -120 0 -80 {
lab=GND}
N -80 -130 -40 -130 {
lab=vref_p}
N -80 -170 -40 -170 {
lab=vcm}
N 0 120 0 160 {
lab=#net1}
N -80 70 -40 70 {
lab=vi1_p}
N -80 110 -40 110 {
lab=vi1_n}
N 80 40 140 40 {
lab=D1}
N 0 220 0 260 {
lab=GND}
N -80 210 -40 210 {
lab=vcm}
N -80 170 -40 170 {
lab=vcm}
N 0 460 0 500 {
lab=#net2}
N -80 410 -40 410 {
lab=vi1_p}
N -80 450 -40 450 {
lab=vi1_n}
N 80 380 140 380 {
lab=D0}
N 0 560 0 600 {
lab=GND}
N -80 550 -40 550 {
lab=vcm}
N -80 510 -40 510 {
lab=vref_p}
N 0 -300 0 -280 {
lab=#net3}
N 0 -220 0 -180 {
lab=#net4}
N 0 40 0 60 {
lab=#net5}
N 0 380 0 400 {
lab=#net6}
N 0 -300 20 -300 {
lab=#net3}
N -0 40 20 40 {
lab=#net5}
N -0 380 20 380 {
lab=#net6}
N -420 -20 -400 -20 {
lab=vclk}
N -340 -20 -320 -20 {
lab=CLK}
N 300 -300 340 -300 {
lab=v_dac_2}
N 320 -260 320 -240 {
lab=GND}
N 320 -260 340 -260 {
lab=GND}
N 380 -250 380 -220 {
lab=vcm}
N 440 -260 440 -240 {
lab=GND}
N 440 -260 460 -260 {
lab=GND}
N 500 -250 500 -220 {
lab=vcm}
N 340 -300 460 -300 {
lab=v_dac_2}
N 500 -340 500 -310 {
lab=i_dac_p}
N 380 -340 380 -310 {
lab=i_dac_n}
N 300 40 340 40 {
lab=v_dac_1}
N 320 80 320 100 {
lab=GND}
N 320 80 340 80 {
lab=GND}
N 380 90 380 120 {
lab=vcm}
N 440 80 440 100 {
lab=GND}
N 440 80 460 80 {
lab=GND}
N 500 90 500 120 {
lab=vcm}
N 340 40 460 40 {
lab=v_dac_1}
N 500 0 500 30 {
lab=i_dac_p}
N 380 0 380 30 {
lab=i_dac_n}
N 300 380 340 380 {
lab=v_dac_0}
N 320 420 320 440 {
lab=GND}
N 320 420 340 420 {
lab=GND}
N 380 430 380 460 {
lab=vcm}
N 440 420 440 440 {
lab=GND}
N 440 420 460 420 {
lab=GND}
N 500 430 500 460 {
lab=vcm}
N 340 380 460 380 {
lab=v_dac_0}
N 500 340 500 370 {
lab=i_dac_p}
N 380 340 380 370 {
lab=i_dac_n}
N 680 100 680 120 {
lab=i_dac_n}
N 680 20 680 40 {
lab=i_dac_p}
N -480 -200 -410 -200 {
lab=vcm}
N -580 -200 -540 -200 {
lab=vref_p}
N 200 -300 240 -300 {
lab=Q2}
N 200 40 240 40 {
lab=Q1}
N 200 380 240 380 {
lab=Q0}
C {devices/adc_bridge.sym} 50 -300 0 0 {name=A1 adc_bridge_model= comp0}
C {devices/vsource.sym} -340 -140 0 0 {name=V2 value=0.9
}
C {devices/vcvs.sym} -270 -280 0 0 {name=E1 value=-0.5}
C {devices/vcvs.sym} -410 -280 0 1 {name=E2 value=0.5}
C {devices/vsource.sym} -340 -270 0 0 {name=VIN value="0 AC 1"
}
C {devices/gnd.sym} -340 -80 0 0 {name=l1 lab=GND}
C {devices/lab_pin.sym} -430 -330 0 0 {name=l3 sig_type=std_logic lab=vi1_p}
C {devices/lab_pin.sym} -250 -330 0 1 {name=l4 sig_type=std_logic lab=vi1_n
}
C {devices/lab_pin.sym} -270 -200 0 1 {name=l2 sig_type=std_logic lab=vcm}
C {devices/lab_pin.sym} -340 -300 1 0 {name=l5 sig_type=std_logic lab=vid}
C {devices/gnd.sym} -340 -230 0 0 {name=l6 lab=GND}
C {devices/vsource.sym} -420 30 0 0 {name=VCLK value="0"
}
C {devices/lab_pin.sym} -420 -30 1 0 {name=p8 sig_type=std_logic lab=vclk}
C {devices/gnd.sym} -420 90 0 0 {name=l7 lab=GND}
C {devices/launcher.sym} -560 340 0 0 {name=h1
descr="Annotate OP"
tclcommand="set show_hidden_texts 1; xschem annotate_op"}
C {sky130_fd_pr/corner.sym} -370 170 0 0 {name=CORNER only_toplevel=false corner=tt}
C {devices/code.sym} -500 170 0 0 {name=STIMULI
only_toplevel=false
value="
a21 D0 ND0 inv1
a22 D1 ND1 inv1
a23 D2 ND2 inv1
*a24 D0 ND0 CLK NULL NULL %d(Q0 NQ0) srff1
*a25 D1 ND1 CLK NULL NULL %d(Q1 NQ1) srff1
*a26 D2 ND2 CLK NULL NULL %d(Q2 NQ2) srff1
a24 D0 CLK NULL NULL %d(Q0 NQ0) dff1
a25 D1 CLK NULL NULL %d(Q1 NQ1) dff1
a26 D2 CLK NULL NULL %d(Q2 NQ2) dff1
a27 NQ1 %d(B1) inv1
a28 [NQ1 Q0] temp1 and1
a29 [Q2 temp1] %d(B0) or1


.model comp0 adc_bridge(in_low=-0.0001 in_high=0.0001)
.model adc_buf adc_bridge(in_low=0.899 in_high=0.901)
.model dac1 dac_bridge(out_low = -1 out_high = 1 out_undef = -1 input_load = 5.0e-12 t_rise = 50e-9 t_fall = 20e-9)
.model switch1 sw vt=0.9 vh=0.05 ron=0.1 roff=100Meg
.model inv1 d_inverter(rise_delay = 0.5e-9 fall_delay = 0.3e-9 input_load = 0.5e-12)
.model and1 d_and(rise_delay = 0.5e-9 fall_delay = 0.3e-9 input_load = 0.5e-12)
.model or1 d_or(rise_delay = 0.5e-9 fall_delay = 0.3e-9 input_load = 0.5e-12)
.model srff1 d_srff(clk_delay = 13.0e-9 set_delay = 25.0e-9 reset_delay = 27.0e-9 ic = 2 rise_delay = 10.0e-9 fall_delay = 3e-9)
.model dff1 d_dff(clk_delay = 13.0e-9 set_delay = 25.0e-9 reset_delay = 27.0e-9 ic = 0 rise_delay = 10.0e-9 fall_delay = 3e-9)

.options savecurrents
.control
save all


let fs = 65536
let fclk = fs
let tper_clk = 1/fclk
let tfr_clk = tper_clk/10
let ton_clk = tper_clk*4/10

let f_sig = 128
let tper_sig = 1/f_sig
let tfr_sig = tper_sig*5/10
let ton_sig = tper_sig*1/1000

alter @VCLK[PULSE]=[ 0 1.8 0 $&tfr_clk $&tfr_clk $&ton_clk $&tper_clk 0 ]
*alter @VIN[PULSE]=[ -0.36 0.36 0 $&tfr_sig $&tfr_sig $&ton_sig $&tper_sig 0 ]
alter @VIN[SIN] = [ 0 0.36 $&f_sig 0 0 0 ]
alter @VIN[DC] = 0.0

let tstep = 0.005/fclk
let tstop = 1/f_sig
let tstart = 0

** Main Simulations


	*dc VIN -0.36 0.36 0.0001	
	tran $&tstep $&tstop $&tstart $&tstep
	
	*setplot dc1
	*plot D0 D1 D2

	setplot tran1
	let data0 = b0
	let data1 = b1
	let iout = @r1[i]
	let iout_plot = iout*0.125e6
	plot vid D0 D1 D2
	*plot D0 ND0
	plot vid B0 B1 iout_plot
	plot vid v_dac_0 v_dac_1 v_dac_2 iout_plot
	plot iout
	eprvcd B1 B0 D2 D1 D0 > "/foss/designs/test_adc.vcd"


op


remzerovec
write adc_dac_macro.raw
.endc"}
C {devices/vsource.sym} -510 -200 3 0 {name=V3 value="0.18"
}
C {devices/vcvs.sym} 0 -250 0 0 {name=E3 value=1}
C {devices/lab_pin.sym} -80 -270 0 0 {name=l11 sig_type=std_logic lab=vi1_p}
C {devices/lab_pin.sym} -80 -230 0 0 {name=l12 sig_type=std_logic lab=vi1_n
}
C {devices/lab_pin.sym} 140 380 3 1 {name=p3 sig_type=std_logic lab=D0}
C {devices/lab_pin.sym} 140 40 3 1 {name=p1 sig_type=std_logic lab=D1}
C {devices/vcvs.sym} 0 -150 0 0 {name=E4 value=1}
C {devices/adc_bridge.sym} 50 40 0 0 {name=A2 adc_bridge_model= comp0}
C {devices/vcvs.sym} 0 90 0 0 {name=E5 value=1}
C {devices/lab_pin.sym} -80 70 0 0 {name=l13 sig_type=std_logic lab=vi1_p}
C {devices/lab_pin.sym} -80 110 0 0 {name=l14 sig_type=std_logic lab=vi1_n
}
C {devices/vcvs.sym} 0 190 0 0 {name=E6 value=1}
C {devices/lab_pin.sym} -80 170 0 0 {name=l18 sig_type=std_logic lab=vcm}
C {devices/lab_pin.sym} 140 -300 3 1 {name=p4 sig_type=std_logic lab=D2}
C {devices/adc_bridge.sym} 50 380 0 0 {name=A3 adc_bridge_model= comp0}
C {devices/vcvs.sym} 0 430 0 0 {name=E7 value=1}
C {devices/lab_pin.sym} -80 410 0 0 {name=l20 sig_type=std_logic lab=vi1_p}
C {devices/lab_pin.sym} -80 450 0 0 {name=l21 sig_type=std_logic lab=vi1_n
}
C {devices/vcvs.sym} 0 530 0 0 {name=E8 value=1}
C {devices/gnd.sym} 0 -80 0 0 {name=l8 lab=GND}
C {devices/lab_pin.sym} -580 -200 0 0 {name=l26 sig_type=std_logic lab=vref_p
}
C {devices/lab_pin.sym} -80 -130 0 0 {name=l15 sig_type=std_logic lab=vref_p
}
C {devices/lab_pin.sym} -80 -170 0 0 {name=l9 sig_type=std_logic lab=vcm}
C {devices/lab_pin.sym} -80 210 0 0 {name=l16 sig_type=std_logic lab=vcm}
C {devices/lab_pin.sym} -80 550 0 0 {name=l19 sig_type=std_logic lab=vcm}
C {devices/gnd.sym} 0 260 0 0 {name=l17 lab=GND}
C {devices/gnd.sym} 0 600 0 0 {name=l22 lab=GND}
C {devices/lab_pin.sym} -80 510 0 0 {name=l23 sig_type=std_logic lab=vref_p
}
C {devices/adc_bridge.sym} -370 -20 0 0 {name=A4 adc_bridge_model= adc_buf}
C {devices/lab_pin.sym} -320 -20 0 1 {name=p2 sig_type=std_logic lab=CLK}
C {devices/dac_bridge.sym} 270 -300 0 0 {name=A5 dac_bridge_model= dac1}
C {devices/dac_bridge.sym} 270 40 0 0 {name=A6 dac_bridge_model= dac1}
C {devices/dac_bridge.sym} 270 380 0 0 {name=A7 dac_bridge_model= dac1}
C {devices/vccs.sym} 380 -280 0 0 {name=G1 value=120n}
C {devices/gnd.sym} 320 -240 0 0 {name=l10 lab=GND}
C {devices/lab_pin.sym} 380 -220 3 0 {name=l24 sig_type=std_logic lab=vcm}
C {devices/vccs.sym} 500 -280 0 0 {name=G2 value=-120n}
C {devices/gnd.sym} 440 -240 0 0 {name=l25 lab=GND}
C {devices/lab_pin.sym} 500 -220 3 0 {name=l27 sig_type=std_logic lab=vcm}
C {devices/lab_pin.sym} 380 -340 1 0 {name=p5 sig_type=std_logic lab=i_dac_n}
C {devices/lab_pin.sym} 500 -340 1 0 {name=p6 sig_type=std_logic lab=i_dac_p}
C {devices/vccs.sym} 380 60 0 0 {name=G3 value=120n}
C {devices/gnd.sym} 320 100 0 0 {name=l28 lab=GND}
C {devices/lab_pin.sym} 380 120 3 0 {name=l29 sig_type=std_logic lab=vcm}
C {devices/vccs.sym} 500 60 0 0 {name=G4 value=-120n}
C {devices/gnd.sym} 440 100 0 0 {name=l30 lab=GND}
C {devices/lab_pin.sym} 500 120 3 0 {name=l31 sig_type=std_logic lab=vcm}
C {devices/lab_pin.sym} 380 0 1 0 {name=p7 sig_type=std_logic lab=i_dac_n}
C {devices/lab_pin.sym} 500 0 1 0 {name=p9 sig_type=std_logic lab=i_dac_p}
C {devices/vccs.sym} 380 400 0 0 {name=G5 value=120n}
C {devices/gnd.sym} 320 440 0 0 {name=l32 lab=GND}
C {devices/lab_pin.sym} 380 460 3 0 {name=l33 sig_type=std_logic lab=vcm}
C {devices/vccs.sym} 500 400 0 0 {name=G6 value=-120n}
C {devices/gnd.sym} 440 440 0 0 {name=l34 lab=GND}
C {devices/lab_pin.sym} 500 460 3 0 {name=l35 sig_type=std_logic lab=vcm}
C {devices/lab_pin.sym} 380 340 1 0 {name=p10 sig_type=std_logic lab=i_dac_n}
C {devices/lab_pin.sym} 500 340 1 0 {name=p11 sig_type=std_logic lab=i_dac_p}
C {devices/lab_pin.sym} 680 20 1 0 {name=p12 sig_type=std_logic lab=i_dac_p}
C {devices/lab_pin.sym} 680 120 3 0 {name=p13 sig_type=std_logic lab=i_dac_n}
C {devices/res.sym} 680 70 0 0 {name=R1
value=1k
footprint=1206
device=resistor
m=1}
C {devices/lab_pin.sym} 320 -300 1 0 {name=p14 sig_type=std_logic lab=v_dac_2}
C {devices/lab_pin.sym} 320 40 1 0 {name=p15 sig_type=std_logic lab=v_dac_1}
C {devices/lab_pin.sym} 320 380 1 0 {name=p16 sig_type=std_logic lab=v_dac_0}
C {devices/lab_pin.sym} 200 -300 1 0 {name=p17 sig_type=std_logic lab=Q2}
C {devices/lab_pin.sym} 200 40 1 0 {name=p18 sig_type=std_logic lab=Q1}
C {devices/lab_pin.sym} 200 380 1 0 {name=p19 sig_type=std_logic lab=Q0}
