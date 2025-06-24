from env import *
import os
import sys
import shutil
import yaml
import json
import time
from datetime import datetime
import subprocess
import hashlib
import json
import random
import time
import functools

# include dacs-lab flow/tech
sys.path.append(DACS_DIR)
from tech.asap7 import Asap7Library
from flow.genus_innovus import GenusInnovusFlow

# include top_module verilog generator script
sys.path.append(ROOT_DIR)

# ===========================================================================

def create_hash(obj):
    hash_hex = hashlib.sha256(obj.encode('utf-8')).hexdigest()
    return hash_hex

def get_file_paths(folder_path):
    file_paths = []
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            file_paths.append(os.path.join(root, file))
    return file_paths

def get_design_config(
    top_module: str
) -> dict:
    """
        get the adder design configuration with specific type and bit
    """

    # all the verilog files
    common_dir = os.path.join(VERILOG_DIR, 'clib')
    adder_dir = os.path.join(VERILOG_DIR, 'adder')
    verilog_files = get_file_paths(common_dir)
    
    # assure that the constants/utils would be firstly compiled
    specified_files = [os.path.join(common_dir,"constant.v"),os.path.join(common_dir,"fp_params.vh")]
    verilog_files = specified_files + [path for path in verilog_files if path not in specified_files]

    # the top_module would be top_module
    design_config = {
        'verilog_files': verilog_files,
        'top_module': top_module,
        'clk_name': 'clock',
        'clk_port_name': 'clock',
    }

    return design_config

def get_tech_config(
) -> dict:
    """
        get standard cell library configuration
    """
    pdk_library = Asap7Library(ASAP7_ROOT).to_dict()
    return  pdk_library


def get_syn_options() -> dict:
    """
        Use Cadence Genus for logic synthesis and set the tool options
    """
    syn_configs = {
        'genus_bin': GENUS_BIN,
        'max_threads': 8,
        'steps': ['syn', 'report'],
        
        ###########################################################################
        # TODO: modify the following synthesis options
        ###########################################################################

        # target timing: float
        'clk_period_ns': 0.0,

        # generic logical synthesis effort: [low/medium/high]
        'syn_generic_effort': 'medium',

        # technology mapping synthesis effort: [low/medium/high]
        'syn_map_effort': 'high',

        # post-synthesis optimization effort: [None/low/medium/high]
        'syn_opt_effort': 'high',

        # fanout constraint: int
        "max_fanout": 20,

        # transition constraint: float
        "max_transition_ns": 0.2,

        # capacitance constraint: float
        "max_capacitance_ff": 50.0,
    }

    return syn_configs


def get_pnr_options(
    macro_placement_code: str = ""
) -> dict:
    """
        Use Cadence Innovus for physical design and set the tool options
    """
    pnr_configs = {
        'innovus_bin': INNOVUS_BIN,
        'max_threads': 8,
        'steps': [
            'init',
            'floorplan',
            'powerplan',
            'placement',
            'cts',      # the adder module is purely combinatorial and does not require CTS stage
            'routing',
        ],
        'runmode': 'skip', #'skip', #'fast',  # use 'skip' if you don't need to run physical design, useful for debugging
        
        ###########################################################################
        # TODO: modify the following synthesis options
        ###########################################################################

        # placement floorplan utilization: float, 0~1
        'place_utilization': 0.6,

        # specify max distance (in micron) for refinePlace ECO mode: float, min=0, max=9999
        'place_detail_eco_max_distance':  10.0,

        # select instance priority for refinePlace ECO mode: [placed/fixed/eco]
        'place_detail_eco_priority_insts':  'placed',

        # detail placement considers optimizing activity power: [true/false]
        'place_detail_activity_power_driven':  'false',

        # wire length optimization effort: [low/medium/high]
        'place_detail_wire_length_opt_effort':  'medium',

        # minimum gap between instances (unit sites): int, default=0
        'place_detail_legalization_inst_gap':  2,

        # Placement will (temporarily) block channels between areas with limited routing capacity: [none/soft/partial]
        'place_global_auto_blockage_in_channel':  'none',

        # identifies and constrains power-critical nets to reduce switching power: [true/false]
        'place_global_activity_power_driven':  'false',

        # power driven effort: [standard/high]
        'place_global_activity_power_driven_effort':  'standard',

        # clock power driven: [true/false]
        'place_global_clock_power_driven':  'true',

        # clock power driven effort: [low/standard/high]
        'place_global_clock_power_driven_effort':  'low',

        # level of effort for timing driven global placer: [meduim/high]
        'place_global_timing_effort':  'medium',

        # level of effort for congestion driven global placer: [low/medium/high/extreme/auto]
        'place_global_cong_effort':  'auto',

        # placement strives to not let density exceed given value, in any part of design: float, default=-1 for no constraint
        # you can set to 0~1
        'place_global_max_density':  0.7,

        # find better placement for clock gating elements towards the center of gravity for fanout: [true/false]
        'place_global_clock_gate_aware':  'true',

        # enable even cell distribution for designs with less than 70% utilization: [true/false]
        'place_global_uniform_density':  'false',

        'macro_placement_code': macro_placement_code

    }

    return pnr_configs


def main():
    """
        Run the complete EDA flow for final PPA
    """

    # get run dir name
    top_module = 'parse_special'

    # initialize run_dir
    os.makedirs(RESULT_DIR, exist_ok=True)
    run_dir = os.path.join(RESULT_DIR, top_module)

    # verilog top module
    design_config = get_design_config(
        top_module
    )

    # configurations
    tech_config = get_tech_config()
    syn_options = get_syn_options()
    pnr_options = get_pnr_options()

    flow = GenusInnovusFlow(
        design_config=design_config,
        tech_config=tech_config,
        syn_options=syn_options,
        pnr_options=pnr_options,
        rundir=run_dir,
    )

    result = flow.run()

    with open(os.path.join(run_dir, 'result.json'), 'w') as f:
        json.dump(result, f, indent=4)

    print(result)

if __name__ == '__main__':
    main()