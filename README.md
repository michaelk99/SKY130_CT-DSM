# A Case Study of an Ultra-Low-Power Delta-Sigma ADC for Biosignal Acquisition
Author: Michael Köfinger, 2023, Johannes Kepler University (JKU) Linz, Austria, Institute for Integrated Circuits (IIC).
This case study was performed in the context of a master thesis, and will be published on the [JKU ePUB repository](https://epub.jku.at/nav/classification/111078).

# Abstract
This thesis performs a case study on an ultra-low-power (ULP) Delta-Sigma analog-
to-digital converter (DS-ADC) for biosignal acquisition utilizing the Institute for
Integrated Circuits (IIC) Open-Source IC (OSIC) tools for the Skywater 130nm
(SKY130) process development kit (PDK). The system-level simulations were based on
Richard Schreier’s ∆Σ toolbox, and loop-filter non-idealities were separately modeled
in MATLAB based on the difference equations of a Delta-Sigma modulator (DSM).
The aim is to identify an alternative system to an existing implementation based on a
cascade of a pre-amplifier and a successive approximation register analog-to-digital
converter (SAR-ADC), see Fig. 1. The scope of this work was set on the DSM, and the decimator
was omitted throughout most parts.
![Existing system, PRE-AMP [1] and SAR-ADC [2], and the alternative structure, a CT DS-ADC.](doc/fig/block_diag_all.png)

**Figure 1**: Existing system, PRE-AMP [1] and SAR-ADC [2], and the alternative structure, a CT DS-ADC. 
# System-Level Design
* Input-referred noise $<1~\mu\mathrm{V}_\mathrm{rms}$
* Input impedance $>100~\mathrm{M}\Omega$
* Input voltage range $\pm260~\mathrm{mV}_\mathrm{peak}$ $(\pm250~\mathrm{mV}_\mathrm{dc}\pm10~\mathrm{mV}_\mathrm{signal})$
* Power consumption $<1~\mu \mathrm{W}$
* Signal bandwidth of $128~\mathrm{Hz}$
* Max. oversampling ratio of $256$
* ADC resolution (LSB) $<0.2~\mu\mathrm{V}_\mathrm{pp}$
* Signal-to-Quantization-Noise-Ratio (SQNR) of $140~\mathrm{dB}$
* Signal-to-Noise-Ratio (SNR) of $130~\mathrm{dB}$

The input-related specifications stem from the target application, which is biosignal acquisition. The rather slow signals have a large source impedance and are in the $\mu\mathrm{V}$ range. Furthermore, contact voltages at the electrode-skin interface must be handled appropriately, which leads to a large input voltage range. Since up to 1024 channels are required, the power consumption of a single channel is limited to only a fraction of the system's power budget. Lastly, the available system clock limits the max. oversampling ratio.

The fact that the DS-ADC should directly interface the signal source, requires the implementation of a continuous-time (CT) DSM, due to its inherent anti-aliasing property.

Since circuit noise should dominate the noise floor, the SQNR was chosen $10~\mathrm{dB}$ larger than the target SNR. Given the fixed OSR and a simple flash quantizer, a 4th-order DSM is necessary, see Fig. 2.

[<img src="doc/fig/sqnrExplore2.png" width="600"/>](doc/fig/sqnrExplore2.png)

**Figure 2**: High-level system design exploration. 

[<img src="doc/fig/dsm_block_diag.png" width="600"/>](doc/fig/dsm_block_diag.png)

**Figure 3**: Block diagram of a DSM with feedback (blue) and feedforward coefficients (red). 

This 4th-order CT-DSM may be either implemented by a feedback (FB), or a feedforward (FF) structure. The block diagram, which depicts both structures is shown in Fig. 3. The corresponding state-space description is:

$
\mathbf{ABCD}=\begin{bmatrix}
		\begin{array}{c|c}
			\mathbf{A} & \mathbf{B}\\
			\hline
			\mathbf{C} & \mathbf{D}
		\end{array}
	\end{bmatrix}=
	\begin{bmatrix}
		\begin{array}{cccc|cc}
			0 & 0 & 0 & 0 & b_{11} & b_{12}\\
			a_{21} & 0 & 0 & 0 & 0 & b_{22}\\
			0 & a_{32} & 0 & 0 & 0 & b_{32}\\
			0 & 0 & a_{43} & 0 & 0 & b_{42}\\
			\hline
			c_1 & c_2 & c_3 & c_4 & 0 & 0
		\end{array}
	\end{bmatrix}
$

In the case of a FB modulator (blue coefficients), the ∆Σ toolbox gave the following set of coefficients:

$
    \mathbf{ABCD}_\textrm{FB}=
	\begin{bmatrix}
		\begin{array}{cccc|cc}
			0 & 0 & 0 & 0 & 0.00614 & -0.00614\\
			1 & 0 & 0 & 0 & 0 & -0.05550\\
			0 & 1 & 0 & 0 & 0 & -0.24946\\
			0 & 0 & 1 & 0 & 0 & -0.67129\\
			\hline
			0 & 0 & 0 & 1 & 0 & 0
		\end{array}
	\end{bmatrix}
$

However, the output of the integrators $x_i$ (Fig. 3) must be scaled to fit within the supply voltage, as shown in Fig. 4. 

[<img src="doc/fig/modStatesScaled.png" width="600"/>](doc/fig/modStatesScaled.png)

**Figure 4**: Internal states of the CIFB CT-DSM after dynamic range scaling, given an input tone with the maximum stable amplitude (MSA). 

However, the 2-bit output sequence $v(t)$ of the quantizer (see Fig. 3 and 4) must be observed in the frequency domain to evaluate the performance (SQNR) of the modulator, as shown in Fig. 5.

[<img src="doc/fig/psdCtAvg.png" width="600"/>](doc/fig/psdCtAvg.png)

**Figure 5**: PSD of the output of the modulator $v(t)$.

# Top Level Schematic
![Top Level Schem](doc/fig/top_schem_2.png)
**Figure 7**: Top-level schematic of the proposed CT-DSM.
# Front-End 
[<img src="doc/fig/frontend.png" width="500"/>](doc/fig/frontend.png)

**Figure 7**: Schematic of the frontend transconductor.

[<img src="doc/fig/auxamp.png" width="500"/>](doc/fig/auxamp.png)

**Figure 8**: Schematic of the auxiliary amplifier of the frontend transconductor.

# Results 

**Table 1**: A comparison with state-of-the-art bidirectional neural recording ICs.

 |Parameter                            | THIS WORK | JSSC19 [3] | JSSC20 [4] |  
 |-------------------------------------|-----------|------------|------------|  
 | Architecture                        | CT-DSM    | CT-DSM    | CT-DSM    |
 | Input Type                          |$G_\mathrm{m}$|$G_\mathrm{m}$|$G_\mathrm{m}$|
 | BW $(\mathrm{kHz})$                 | $0.128$  |$0.2$     | $10$       |
 | Technology $(\mathrm{nm})$          | $130$    |$180$     | $110$      |
 | Open Source Technology              | yes      |no        | no      |
 | Supply $(\mathrm{V})$               | $1.8$    |$1.2$     | $1.0$   |
 | Input Signal Range $(\mathrm{mV}_\mathrm{pp})$|$\pm 300$ |$\pm 100$ | $\pm 150$|
 | Target SNR $(\mathrm{dB})$          | $130$        |$80$     | $80$         | 
 | OSR                                 | $256$       |$2048$     |$64$        | 
 | Quantizer Type                      |Flash    |Time-based     |Time-based       |
 | Quantizer Bits                      |$1$    |$5$     |$4$        |
 | Noise-Shaping Order                 |$4$    |$1$     |$2$      |
 | Total Input Noise $(\mu\mathrm{V}_\mathrm{rms})$  |$3.9$   |$1.3$     |$9.5$ |
 | Eq. Input Noise Density $^a$ $(\mathrm{V}/\sqrt{\mathrm{Hz}})$ |$345$|$92$| $95$ |  
 | Aux. Amp. W/L Input Pair $(\mu\mathrm{m}/\mu\mathrm{m})$    |$500/10$ |-|$250/1.6$  |
 | Aux. Amp. W/L Casc. CS $^b$ $(\mu\mathrm{m}/\mu\mathrm{m})$  |$40/80$ |-|$12/24$     |
 | Power Consumption Input $G_\mathrm{m}$ $(\mu\mathrm{W})$  |$8.8^c$ |$2.4$ |$4.2$       |

$^a$ Equivalent white noise spectral density based on parameters “BW” and “Total Input Noise”.

$^b$ Current source devices of the folded cascodes, $M_{11}$ and $M_{12}$ in Figure 8.

$^c$ Estimate based on 70% bias current reduction of the main transconductor (Feedback Assisted $G_\mathrm{m}$ Linearization). The final value was doubled to take the CMFB circuit into account.

# References
[1] S. Schmickl, T. Schumacher, P. Fath, T. Faseth and H. Pretl, "A 350-nW Low-Noise Amplifier With Reduced Flicker-Noise for Bio-Signal Acquisition," 2020 Austrochip Workshop on Microelectronics (Austrochip), Vienna, Austria, 2020, pp. 9-12, doi: 10.1109/Austrochip51129.2020.9232981.

[2] S. Schmickl, T. Faseth and H. Pretl, "An Untrimmed 14-bit Non-Binary SAR-ADC Using 0.37 fF-Capacitors in 180 nm for 1.1 µW at 4 kS/s," 2020 27th IEEE International Conference on Electronics, Circuits and Systems (ICECS), Glasgow, UK, 2020, pp. 1-4, doi: 10.1109/ICECS49266.2020.9294971.

[3] H. Jeon, J. -S. Bang, Y. Jung, I. Choi and M. Je, "A High DR, DC-Coupled, Time-Based Neural-Recording IC With Degeneration R-DAC for Bidirectional Neural Interface," in IEEE Journal of Solid-State Circuits, vol. 54, no. 10, pp. 2658-2670, Oct. 2019, doi: 10.1109/JSSC.2019.2930903.

[4] C. Lee et al., "A 6.5-μW 10-kHz BW 80.4-dB SNDR Gm-C-Based CT ∆∑ Modulator With a Feedback-Assisted Gm Linearization for Artifact-Tolerant Neural Recording," in IEEE Journal of Solid-State Circuits, vol. 55, no. 11, pp. 2889-2901, Nov. 2020, doi: 10.1109/JSSC.2020.3018478.
