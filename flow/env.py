# setup environment variables

import os
import sys

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(ROOT_DIR)

DACS_DIR = os.path.join(ROOT_DIR, "3rd/dacs")

VERILOG_DIR = os.path.join(ROOT_DIR, "verilog")

ASAP7_ROOT = '/storage/eda/asap7'

GENUS_BIN = '/soft/cadence/genus/19.12.000/bin/genus'

INNOVUS_BIN = '/soft/cadence/innovus/innovus21.14/bin/innovus'

RESULT_DIR = os.path.join(ROOT_DIR, "result")