#!/usr/bin/env python3
# A very simple and stupid test script.
# For each asm/*.asm, compare the output of pinot_asm to bin/*.bin.
# Assumptions:
#   - The pinot_asm project has been built.
#   - This script is being run from the examples directory.

import os
import sys

# The path to the pinot_asm exectutable.
EXE = "../pinot_asm/pinot_asm"
# The default file produced by pinot_asm.
OUTPUT = "a.bin"
# The path that contains the test inputs.
ASM_DIR = "asm"
# The path that contains the expected outputs.
BIN_DIR = "bin"

# Remove the path. Ignore non existence failures.
def remove_if_exists(path):
    try:
        os.unlink(path)
    except FileNotFoundError:
        pass

# Read path into an array, or return None on failure.
def read_bin(path):
    try:
        with open(path, "rb") as f:
            return f.read()
    except:
        print(f"Couldn't open {path} for reading.")
        return None

# Test input_path. Return True on success, False on failure.
def run_test(input_path, expected_output_path):
    # Read the expected output file before going any further.
    expected_arr = read_bin(expected_output_path)
    if expected_arr == None:
        return False
    # Remove any existing a.bin so we don't get confused.
    remove_if_exists(OUTPUT)
    # Run pinot_asm, passing input_path as the argument.
    os.system(f"{EXE} {input_path}")
    # Read the output.
    output_arr = read_bin(OUTPUT)
    if output_arr == None:
        return False
    return output_arr == expected_arr

# Test all files in asm, returning 1 on failure or 0 on success.
if __name__ == "__main__":
    # For each *.asm in asm.
    failures = 0
    directory = os.fsencode(ASM_DIR)
    for file in os.listdir(directory):
        asm_filename = os.fsdecode(file)
        # If *.asm exists, call run_test(asm/*.asm, bin/*.bin)
        # (The latter may not exist.)
        if asm_filename.endswith(".asm"):
            bin_filename = asm_filename.rsplit(".", 1)[0] + ".bin"
            asm_path = os.path.join(ASM_DIR, asm_filename)
            bin_path = os.path.join(BIN_DIR, bin_filename)
            if run_test(asm_path, bin_path):
                print(f"{asm_path}: PASS")
            else:
                print(f"{asm_path}: FAIL")
                failures += 1
    if failures == 0:
        sys.exit(0)
    else:
        sys.exit(1)
