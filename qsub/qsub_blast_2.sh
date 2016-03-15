#!/bin/bash

# ----------------QSUB Parameters----------------- #
#PBS -S /bin/bash
#PBS -q aces
#PBS -l nodes=1:ppn=12
#PBS -l walltime=160:00:00
#PBS -t 31-48
# ----------------Load Modules-------------------- #
# ----------------Your Commands------------------- #
cd /home/sadkhin2/phytozome11/Oogle_2016
mkdir logs
./blast.pl $PBS_ARRAYID > logs/$PBS_ARRAYID.log 

