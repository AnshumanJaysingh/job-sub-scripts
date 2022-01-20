#!/bin/bash
# Parallel job submission script:
# Usage: qsub  <this_script>
#
# The shell used to run the job
#$ -S /bin/bash
#
# The name of the parallel queue to submit the job to
# Define the parallel runtime environment and number of nodes
# NB: number of nodes is one more than needed as one copy resideson the master node
#$ -pe mpi 48
# Use location that job was submitted as working directory
#$ -cwd
#
# Export all environment variables to the slave jobs
#$ -V
#
# Put stdout & stderr into the same file
#$ -j y
#
# The name of the SGE logfile for this job
#$ -o output.log
module load intel-compiler-2018
source /home/softwares/intel_2018/impi/2018.3.222/intel64/bin/mpivars.sh
source /home/softwares/gromacs/bin/GMXRC

gmx_mpi grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o production1.tpr
mpirun -iface ib0 -np $NSLOTS gmx_mpi mdrun -deffnm production1

#mpiexec -iface ib0 -f /home/softwares/Hostfiles/hosts.ifc -np $NSLOTS ./heat
#./hello
