v {xschem version=3.1.0 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 40 100 40 120 {
lab=VSS}
N -40 50 0 50 {
lab=VO_N}
N -40 -50 0 -50 {
lab=VO_P}
N 270 80 290 80 {
lab=VFB}
N 0 -10 0 20 {
lab=#net1}
N 0 20 40 20 {
lab=#net1}
N 40 20 40 40 {
lab=#net1}
N 40 120 150 120 {
lab=VSS}
N 150 100 150 120 {
lab=VSS}
N 110 90 110 120 {
lab=VSS}
N 0 90 0 120 {
lab=VSS}
N 0 120 40 120 {
lab=VSS}
N 110 -60 110 50 {
lab=#net2}
N 40 -80 110 -80 {
lab=#net2}
N 110 -80 110 -60 {
lab=#net2}
N 150 20 150 40 {
lab=VCM_IN}
N 150 20 200 20 {
lab=VCM_IN}
N 200 80 210 80 {
lab=VSS}
N 200 20 220 20 {
lab=VCM_IN}
N 220 20 220 40 {
lab=VCM_IN}
N 200 80 200 120 {
lab=VSS}
N 150 120 200 120 {
lab=VSS}
N 220 10 220 20 {
lab=VCM_IN}
N 40 0 90 0 {
lab=VSS}
N 90 0 90 120 {
lab=VSS}
N 100 120 100 140 {
lab=VSS}
N 260 20 370 20 {
lab=VCM}
N -40 180 240 180 {
lab=VCM}
N 240 180 370 180 {
lab=VCM}
N 370 20 370 180 {
lab=VCM}
N 100 140 100 230 {
lab=VSS}
N -40 230 100 230 {
lab=VSS}
N 260 20 260 40 {
lab=VCM}
N 220 -10 220 10 {
lab=VCM_IN}
N 220 -10 290 -10 {
lab=VCM_IN}
N 40 -80 40 -60 {
lab=#net2}
C {devices/vcvs.sym} 40 70 0 0 {name=E3 value=-1
}
C {devices/vcvs.sym} 40 -30 0 0 {name=E4 value=1}
C {devices/vcvs.sym} 150 70 0 0 {name=E5 value=0.5}
C {devices/vcvs.sym} 240 80 1 0 {name=E6 value=\{ACM\}

}
C {devices/ipin.sym} -40 -50 0 0 {name=p1 lab=VO_P}
C {devices/ipin.sym} -40 50 0 0 {name=p2 lab=VO_N}
C {devices/ipin.sym} -40 180 0 0 {name=p3 lab=VCM}
C {devices/ipin.sym} -40 230 0 0 {name=p4 lab=VSS}
C {devices/opin.sym} 290 80 0 0 {name=p5 lab=VFB}
C {devices/opin.sym} 290 -10 0 0 {name=p6 lab=VCM_IN}
