
# combining anaconda & pip: https://www.anaconda.com/using-pip-in-a-conda-environment/
conda search scanpy
conda info --envs
conda activate scrna # make sure to switch to that environment
conda install pip
/scratchLocal/frd2007/software/anaconda3/envs/scrna/bin/pip install scanorama

## testing scanorama
 wget https://raw.githubusercontent.com/brianhie/scanorama/master/bin/process.py --no-check-certificate
 
 

