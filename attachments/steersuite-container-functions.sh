cogtarget=develop
sif_file=$HOME/Projects/CLionProjects/SteerSuite-P2/main/steersim.sif

# run a command with singularity container (ARGS: command and argument to run)
singrun () {
singularity run -e --env-file $HOME/.apptainer.env $sif_file $*
}

# start a shell in singularity container (ARGS: other options)
singshell () {
singularity shell -s /bin/bash $* $sif_file
}

kdai_repo=/home/kaidong/Projects/CLionProjects/kdai-module/develop
# compile CogAI library
smake () {
singrun make $* -C $kdai_repo |& tee $kdai_repo/build/make.log
}

binpath=/home/kaidong/Projects/CLionProjects/SteerSuite-P2/cogai-scene/build/bin
# run steersim with default config file (ARGS: optional gdb --args for debugging)
srun () {
pushd $binpath >/dev/null
singrun $* ./steersim -config steersim-config.xml
popd >/dev/null
}
