# A Case Study of an Ultra-Low-Power Delta-Sigma ADC for Biosignal Acquisition
Author: Michael Köfinger, 2023, Johannes Kepler University (JKU) Linz, Austria, Institute for Integrated Circuits (IIC).
This case study was performed in the context of a master thesis, and will be published on the [JKU ePUB repository](https://epub.jku.at/nav/classification/111078).

# Abstract
![Existing system, PRE-AMP [1] and SAR-ADC [2], and the alternative structure, a CT DS-ADC.](doc/fig/block_diag_all.png)
**Figure 1**: Existing system, PRE-AMP [1] and SAR-ADC [2], and the alternative structure, a CT DS-ADC. 

# System-Level Design
[<img src="doc/fig/sqnrExplore2.png" width="600"/>](doc/fig/sqnrExplore2.png)

**Figure 2**: High-level system design exploration. 

# Feedback vs. Feedforward Loop Filter
[<img src="doc/fig/dsm_block_diag.png" width="600"/>](doc/fig/dsm_block_diag.png)

**Figure 3**: Block diagram of a DSM with feedback (blue) and feedforward coefficients (red). 

[<img src="doc/fig/modStatesScaled.png" width="600"/>](doc/fig/modStatesScaled.png)

**Figure 4**: Internal states of the CIFB CT-DSM after dynamic range scaling, given an input tone with the maximum stable amplitude (MSA). 

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
 | Input Signal Range $(\mathrm{mVpp})$|$\pm 300$ |$\pm 100$ | $\pm 150$|
 | Target SNR $(\mathrm{dB})$          | $130$        |$80$     | $80$         | 
 | OSR                                 | $256$       |$2048$     |$64$        | 
 | Quantizer Type                      |Flash    |Time-based     |Time-based       |
 | Quantizer Bits                      |$1$    |$5$     |$4$        |
 | Noise-Shaping Order                 |$4$    |$1$     |$2$      |
 | Total Input Noise $(µ\mathrm{V}_\mathrm{rms})$  |$3.9$   |$1.3$     |$9.5$ |
 | Eq. Input Noise Density $^a$ $(\mathrm{V}/\sqrt{\mathrm{Hz}})$ |$345$|$92$| $95$ |  
 | Aux. Amp. W/L Input Pair $(µ\mathrm{m}/µ\mathrm{m})$    |$500/10$ |-|$250/1.6$  |
 | Aux. Amp. W/L Casc. CS $^b$ $(µ\mathrm{m}/µ\mathrm{m})$  |$40/80$ |-|$12/24$     |
 | Power Consumption Input $G_\mathrm{m}$ $(µ\mathrm{W})$  |$8.8^c$ |$2.4$ |$4.2$       |

$^a$ Equivalent white noise spectral density based on parameters “BW” and “Total Input Noise”.  
$^b$ Current source devices of the folded cascodes, $M_{11}$ and $M_{12}$ in Figure 8.
$^c$ Estimate based on 70% bias current reduction of the main transconductor (Feedback Assisted $G_\mathrm{m}$ Linearization). The final value was doubled to take the CMFB circuit into account.

# References
[1] S. Schmickl, T. Schumacher, P. Fath, T. Faseth and H. Pretl, "A 350-nW Low-Noise Amplifier With Reduced Flicker-Noise for Bio-Signal Acquisition," 2020 Austrochip Workshop on Microelectronics (Austrochip), Vienna, Austria, 2020, pp. 9-12, doi: 10.1109/Austrochip51129.2020.9232981.

[2] S. Schmickl, T. Faseth and H. Pretl, "An Untrimmed 14-bit Non-Binary SAR-ADC Using 0.37 fF-Capacitors in 180 nm for 1.1 µW at 4 kS/s," 2020 27th IEEE International Conference on Electronics, Circuits and Systems (ICECS), Glasgow, UK, 2020, pp. 1-4, doi: 10.1109/ICECS49266.2020.9294971.

[3] H. Jeon, J. -S. Bang, Y. Jung, I. Choi and M. Je, "A High DR, DC-Coupled, Time-Based Neural-Recording IC With Degeneration R-DAC for Bidirectional Neural Interface," in IEEE Journal of Solid-State Circuits, vol. 54, no. 10, pp. 2658-2670, Oct. 2019, doi: 10.1109/JSSC.2019.2930903.

[4] C. Lee et al., "A 6.5-μW 10-kHz BW 80.4-dB SNDR Gm-C-Based CT ∆∑ Modulator With a Feedback-Assisted Gm Linearization for Artifact-Tolerant Neural Recording," in IEEE Journal of Solid-State Circuits, vol. 55, no. 11, pp. 2889-2901, Nov. 2020, doi: 10.1109/JSSC.2020.3018478.
