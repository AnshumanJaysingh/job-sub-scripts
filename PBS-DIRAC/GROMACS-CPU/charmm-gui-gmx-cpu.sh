########################## If you proceed in Dirac ###########################
#!/bin/bash
# Parallel job submission script:
# Usage: qsub -q ncore.q <this_script>
#
# The shell used to run the job
#$ -S /bin/bash
#
# The name of the parallel queue to submit the job to
# Define the parallel runtime environment and number of nodes
# NB: number of nodes is one more than needed as one copy resideson the master node
#$ -pe mpi 32
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
source /home/softwares/gromacs/bin/GMXRC
source /home/softwares/intel_2018/impi/2018.3.222/intel64/bin/mpivars.sh
#export CUDA_HOME=/opt/cuda_10.0.130
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CUDA_HOME}/lib64:${CUDA_HOME}/lib64/stubs

# Minimization
#setenv GMX_MAXCONSTRWARN -1

# step6.0 - soft-core minimization
gmx_mpi grompp -f step6.0_minimization.mdp -o step6.0_minimization.tpr -c step5_charmm2gmx.pdb -r step5_charmm2gmx.pdb -p system.top -n index.ndx
gmx_mpi mdrun -v -rdd 3.0 -deffnm step6.0_minimization

# step6.1
gmx_mpi grompp -f step6.1_minimization.mdp -o step6.1_minimization.tpr -c step6.0_minimization.gro -r step5_charmm2gmx.pdb -p system.top -n index.ndx
gmx_mpi mdrun -v -rdd 3.0 -deffnm step6.1_minimization
#unsetenv GMX_MAXCONSTRWARN

#step6.2
gmx_mpi grompp -f step6.2_equilibration.mdp -o step6.2_equilibration.tpr -c step6.1_minimization.gro -r step5_charmm2gmx.pdb -p system.top -n index.ndx
gmx_mpi mdrun -v -rdd 3.0 -deffnm step6.2_equilibration

#step6.3
gmx_mpi grompp -f step6.3_equilibration.mdp -o step6.3_equilibration.tpr -c step6.2_equilibration.gro -r step5_charmm2gmx.pdb -p system.top -n index.ndx
gmx_mpi mdrun -v -rdd 3.0 -deffnm step6.3_equilibration

#step6.4
gmx_mpi grompp -f step6.4_equilibration.mdp -o step6.4_equilibration.tpr -c step6.3_equilibration.gro -r step5_charmm2gmx.pdb -p system.top -n index.ndx
gmx_mpi mdrun -v -rdd 3.0 -deffnm step6.4_equilibration

#step6.5
gmx_mpi grompp -f step6.5_equilibration.mdp -o step6.5_equilibration.tpr -c step6.4_equilibration.gro -r step5_charmm2gmx.pdb -p system.top -n index.ndx
gmx_mpi mdrun -v -rdd 3.0 -deffnm step6.5_equilibration

#step6.6
gmx_mpi grompp -f step6.6_equilibration.mdp -o step6.6_equilibration.tpr -c step6.5_equilibration.gro -r step5_charmm2gmx.pdb -p system.top -n index.ndx
gmx_mpi mdrun -v -rdd 3.0 -deffnm step6.6_equilibration -s step6.5_equilibration.tpr

#Production run
gmx_mpi grompp -f md1us.mdp -o md1us.tpr -c step6.6_equilibration.gro -p system.top -n index.ndx -maxwarn -1
mpirun -iface ib0 -np $NSLOTS gmx_mpi mdrun -v -deffnm md1us

