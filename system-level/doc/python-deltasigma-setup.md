# Requirements

+ Code (incl. python-deltasigma toolbox) from Git repo. [1] 
	+ download/clone to `<install-path>`

+ Python 3

+ Miniconda

+ Jupyter Notebook or VS Code

# Setup

+ Create virtual python environment with conda (`<conda-env-name>`)
	+ `conda create -n <conda-env-name> python=3.10.6 ipykernel cython`

+ Activate new environment
	+ `conda activate <conda-env-name>`

+ Install packages
	+ `cd <install-path>/SKY130_CT-DSM/python-deltasigma`
	
	+ `python setup.py install`
	
	+ `pip install control`

+ Open Jupyter-Notebook or use VS Code

+ Open design exploration notebook (`<install-path>/SKY130_CT-DSM/system-level/python/system_design_exploration.ipynb`)

+ VS Code: select `<conda-env-name>` as kernel

+ VS Code: `Run All`

# Troubleshooting

+ If toolbox functions do not work, check python version. Versions `3.10.6`, `3.9.5`, and `3.9.7` were tested succesfully.
	1. `conda activate <conda-env-name>`
	2. `conda install python=3.9.7`

+ Due to some unkown reason, python-deltasigma does not use the faster simulation backend, even though Cython is installed.

# Additional Commands/Hints

+ Remove conda environment
	1. `conda deactivate`
	2. `conda env remove -n <conda-env-name>`
	
+ Clean Run in VS Code
	1. `Clear All Outputs`
	2. `Restart`
	3. `Run All`

# References

[1] Github Repo, https://github.com/michaelk99/SKY130_CT-DSM/
