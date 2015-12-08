#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage ./run_asm.sh <proc name>"
	exit
fi

simdut=${1}_dut

asm_tests=(
  lw
  )

asm_tests=(
    cache
    simple
    add addi
	and andi
	auipc
	beq bge bgeu blt bltu bne
	j jal jalr
	lw
	lui
	or ori
	sw
	sll slli
	slt slti
	sra srai
	srl srli
	sub
	xor xori
	bpred_bht bpred_j bpred_j_noloop bpred_ras
	cache cache_conflict stq
	)

vmh_dir=../../programs/build/assembly/vmh
log_dir=logs
wait_time=3

# create bsim log dir
mkdir -p ${log_dir}

# kill previous bsim if any
pkill bluetcl

# run each test
for test_name in ${asm_tests[@]}; do
	# copy vmh file
	mem_file=${vmh_dir}/${test_name}.riscv.vmh
	if [ ! -f $mem_file ]; then
		echo "ERROR: $mem_file does not exit, you need to first compile"
		exit
	fi
	cp ${mem_file} mem.vmh 

	# run test
	./${simdut} > ${log_dir}/${test_name}.log & # run bsim, redirect outputs to log
	sleep ${wait_time} # wait for bsim to setup
	./tb $mem_file # run test bench
	echo ""
done
