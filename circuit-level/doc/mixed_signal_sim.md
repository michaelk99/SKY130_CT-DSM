# Requirements

+ Working conda environment as described in `system-level/doc/python-deltasigma-setup.md`

+ Python Package *vcdvcd*

# Setup

+ Change directory to `<install-path>`
	+ `cd <install-path>`

+ Install VCD file parser *vcdvcd*
	+ `conda activate <conda-env-name>`
	
	+ `pip install vcdvcd`

# Simulation

+ Run transient simulation 
	+ Warning! Adjust `N_per` ('STIMULI' code block) to `N_per = 2` if you want to verify the operation first, otherwise the simulation will take a few minutes.
	
	+ Run Ngspice: `circuit-level/xschem/dsm/ctmod4_2bit_fb.sch`
		+ Output file: e.g.`circuit-level/xschem/dsm/ctdsm4_out.vcd`
	
+ Convert VCD file into MATLAB readable format
	
	+ `python circuit-level/python/vcd2mat.py circuit-level/xschem/dsm/ctdsm4_out.vcd <matlab-output-path>`
	
+ Calculate PSD w/ MATLAB script `circuit-design/matlab/analyze_ms_results.m`

	+ Set correct path to load `<matlab-output-path>`
	
	+ Run MATLAB script

# Troubleshooting


# Additional Commands/Hints


# References


