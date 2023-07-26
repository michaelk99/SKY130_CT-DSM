# Requirements

+ Working conda environment as described in `doc/python-deltasigma-setup.md`

+ Python Package *vcdvcd*

+ A working docker containter w/ the IIC-OSIC-TOOLS [1]

	+ `<iic-osic-tools-path>`

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

+ Set IIC-OSIC-TOOLS designs directory before launching the docker container

	+ `export DESIGNS=<install-path>/circuit-level/xschem`
	
	+ `<iic-osic-tools-path>/start_x.sh`

+ An example VCD file is provided here:

	+ https://drive.proton.me/urls/WB7YPXWQSG#NQw5xVjYElBJ

# References

[1] IIC-OSIC-TOOLS Docker Containter, https://github.com/iic-jku/iic-osic-tools
