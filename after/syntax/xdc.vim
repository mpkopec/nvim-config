" Ported from vim-polyglot's syntax/xdc.vim (Amal Khailtash, based on the SDC
" Vim syntax file) so XDC highlighting doesn't depend on vim-polyglot.
runtime! syntax/tcl.vim

" ----------------------------------------------------------------------------------------------------------------------
" SDC-specific keywords
" ----------------------------------------------------------------------------------------------------------------------
syntax keyword sdcOperatingConditions                  set_operating_conditions
syntax keyword sdcSystemInterface                      set_load
syntax keyword sdcTimingConstraints                    create_clock create_generated_clock group_path
syntax keyword sdcTimingConstraints                    set_clock_groups set_clock_latency set_clock_sense
syntax keyword sdcTimingConstraints                    set_clock_uncertainty set_data_check set_disable_timing
syntax keyword sdcTimingConstraints                    set_input_delay set_max_time_borrow set_output_delay
syntax keyword sdcTimingConstraints                    set_propagated_clock
syntax keyword sdcTimingExceptions                     set_false_path set_max_delay set_min_delay set_multicycle_path
syntax keyword sdcLogicAssignments                     set_case_analysis set_logic_dc set_logic_one set_logic_zero
syntax keyword sdcObjectAccessCommands                 all_clocks all_fanin all_fanout all_inputs all_outputs
syntax keyword sdcObjectAccessCommands                 all_registers current_design get_cells get_clocks get_nets
syntax keyword sdcObjectAccessCommands                 get_pins get_ports get_timing_arcs get_timing_paths
syntax keyword sdcGeneralPurposeCommands               current_instance set_hierarchy_separator set_units

" ----------------------------------------------------------------------------------------------------------------------
" Unsupported SDC Commands
" ----------------------------------------------------------------------------------------------------------------------
syntax keyword sdcCollection_Unsupported               foreach_in_collection
syntax keyword sdcWireLoadModels_Unsupported           set_wire_load_min_block_size set_wire_load_mode
syntax keyword sdcWireLoadModels_Unsupported           set_wire_load_model set_wire_load_selection_group
syntax keyword sdcSystemInterface_Unsupported          set_drive set_driving_cell set_fanout_load
syntax keyword sdcSystemInterface_Unsupported          set_input_transition set_port_fanout_number
syntax keyword sdcDesignRuleConstraints_Unsupported    set_max_capacitance set_min_capacitance set_max_fanout
syntax keyword sdcDesignRuleConstraints_Unsupported    set_max_transition
syntax keyword sdcTimingConstraints_Unsupported        set_clock_gating_check
syntax keyword sdcTimingConstraints_Unsupported        set_clock_transition
syntax keyword sdcTimingConstraints_Unsupported        set_ideal_latency set_ideal_network set_ideal_transition
syntax keyword sdcTimingConstraints_Unsupported        set_resistance set_timing_derate
syntax keyword sdcAreaConstraints_Unsupported          set_max_area
syntax keyword sdcMultivoltagePowerOpt_Unsupported     create_voltage_area set_level_shifter_strategy
syntax keyword sdcMultivoltagePowerOpt_Unsupported     set_level_shifter_threshold set_max_dynamic_power
syntax keyword sdcMultivoltagePowerOpt_Unsupported     set_max_leakage_power
syntax keyword sdcAltera_Unsupported                   create_timing_netlist update_timing_netlist

" ----------------------------------------------------------------------------------------------------------------------
" XDC-specific extension keywords
" ----------------------------------------------------------------------------------------------------------------------
syntax keyword xdcOperatingConditions                  report_operating_conditions reset_operating_conditions
syntax keyword xdcTimingConstraints                    set_input_jitter set_external_delay set_system_jitter
syntax keyword xdcLogicAssignments                     set_logic_unconnected
syntax keyword xdcObjectAccessCommands                 all_cpus all_dsps all_ffs all_hsios all_latches all_rams
syntax keyword xdcObjectAccessCommands                 get_generated_clocks get_iobanks get_package_pins
syntax keyword xdcObjectAccessCommands                 get_path_groups get_sites filter set_property
syntax keyword xdcGeneralPurposeCommands               get_hierarchy_separator
syntax keyword xdcFloorplanCommands                    add_cells_to_pblock create_pblock delete_pblock get_pblocks
syntax keyword xdcFloorplanCommands                    remove_cells_from_pblock resize_pblock
syntax keyword xdcPowerCommands                        set_default_switching_activity set_power_opt
syntax keyword xdcPowerCommands                        set_switching_activity
syntax keyword xdcPinPlanningCommands                  set_package_pin_val

" ----------------------------------------------------------------------------------------------------------------------
" Constants
" ----------------------------------------------------------------------------------------------------------------------
syntax keyword xdcConstant                             NO YES FALSE TRUE DISABLE ENABLE NONE BACKBONE SLOW FAST DONTCARE
syntax keyword xdcConstant                             NORMAL HIGH IBUF IFD BOTH HALT CONTINUE CORRECT_AND_CONTINUE
syntax keyword xdcConstant                             CORRECT_AND_HALT PRE_COMPUTED FIRST_READBACK
syntax keyword xdcConstant                             DIFF_HSTL_I DIFF_HSTL_II DIFF_HSTL_II_18 DIFF_HSTL_II_DCI
syntax keyword xdcConstant                             DIFF_HSTL_II_DCI_18 DIFF_HSTL_II_T_DCI DIFF_HSTL_II_T_DCI_18
syntax keyword xdcConstant                             DIFF_HSTL_II__T_DCI DIFF_HSTL_I_18 DIFF_HSTL_I_DCI
syntax keyword xdcConstant                             DIFF_HSTL_I_DCI_18 DIFF_HSUL_12_DCI DIFF_SSTL12_DCI
syntax keyword xdcConstant                             DIFF_SSTL12_T_DCI DIFF_SSTL135 DIFF_SSTL135_DCI DIFF_SSTL135_R
syntax keyword xdcConstant                             DIFF_SSTL135_T_DCI DIFF_SSTL15 DIFF_SSTL15_DCI DIFF_SSTL15_R
syntax keyword xdcConstant                             DIFF_SSTL15_T_DCI DIFF_SSTL18_I DIFF_SSTL18_II DIFF_SSTL18_II_DCI
syntax keyword xdcConstant                             DIFF_SSTL18_II_T_DCI DIFF_SSTL18_I_DCI HSLVDCI_15 HSLVDCI_18 HSTL_I
syntax keyword xdcConstant                             HSTL_II HSTL_II_18 HSTL_II_DCI HSTL_II_DCI_18 HSTL_II_T_DCI
syntax keyword xdcConstant                             HSTL_II_T_DCI_18 HSTL_I_18 HSTL_I_DCI HSTL_I_DCI_18 HSUL_12_DCI
syntax keyword xdcConstant                             LVCMOS12 LVCMOS18 LVCMOS25 LVDCI_15 LVDCI_18 LVDCI_DV2_15 LVDS
syntax keyword xdcConstant                             LVDCI_DV2_18 SSTL12_DCI SSTL12_T_DCI SSTL135 SSTL135_DCI SSTL135_R
syntax keyword xdcConstant                             SSTL135_T_DCI SSTL15 SSTL15_DCI SSTL15_R SSTL15_T_DCI SSTL18_I
syntax keyword xdcConstant                             SSTL18_II SSTL18_II_DCI SSTL18_II_T_DCI SSTL18_I_DCI
syntax keyword xdcConstant                             TUNED_SPLIT UNTUNED_SPLIT_25 UNTUNED_SPLIT_40 UNTUNED_SPLIT_50
syntax keyword xdcConstant                             UNTUNED_SPLIT_60 UNTINED_SPLIT_75 TUNED UNTUNED_25 UNTUNED_50
syntax keyword xdcConstant                             UNTUNED_75

" LVCMOS33 missing from vim-polyglot xdc.vim — remove once upstream is fixed
syntax keyword xdcConstant                             LVCMOS33

" ----------------------------------------------------------------------------------------------------------------------
" Properties
" ----------------------------------------------------------------------------------------------------------------------
syntax keyword xdcProperty                             ASYNC_REG BEL CLOCK_DEDICATED_ROUTE COMPATIBLE_CONFIG_MODES
syntax keyword xdcProperty                             DCI_CASCADE DIFF_TERM DONT_TOUCH DRIVE HIODELAY_GROUP HLUTNM IN_TERM
syntax keyword xdcProperty                             INTERNAL_VREF IOB IODELAY_GROUP IOSTANDARD KEEP_HIERARCHY KEEPER LOC
syntax keyword xdcProperty                             LUTNM MARK_DEBUG OUT_TERM PACKAGE_PIN POST_CRC POST_CRC_ACTION
syntax keyword xdcProperty                             POST_CRC_FREQ POST_CRC_INIT_FLAG POST_CRC_SOURCE PROHIBIT PULLDOWN
syntax keyword xdcProperty                             PULLUP SLEW VCCAUX_IO

" ----------------------------------------------------------------------------------------------------------------------
" Command Flags
" ----------------------------------------------------------------------------------------------------------------------
syntax match   xdcFlags                                "[[:space:]]-[[:alpha:]]*\>"

" ----------------------------------------------------------------------------------------------------------------------
" Default highlighting
" ----------------------------------------------------------------------------------------------------------------------
highlight default link sdcOperatingConditions                  Operator
highlight default link sdcSystemInterface                      Operator
highlight default link sdcTimingConstraints                    Operator
highlight default link sdcTimingExceptions                     Operator
highlight default link sdcLogicAssignments                     Operator
highlight default link sdcObjectAccessCommands                 Operator
highlight default link sdcGeneralPurposeCommands               Operator

highlight default link sdcCollection_Unsupported               WarningMsg
highlight default link sdcWireLoadModels_Unsupported           WarningMsg
highlight default link sdcSystemInterface_Unsupported          WarningMsg
highlight default link sdcDesignRuleConstraints_Unsupported    WarningMsg
highlight default link sdcTimingConstraints_Unsupported        WarningMsg
highlight default link sdcAreaConstraints_Unsupported          WarningMsg
highlight default link sdcMultivoltagePowerOpt_Unsupported     WarningMsg
highlight default link sdcAltera_Unsupported                   WarningMsg

highlight default link xdcOperatingConditions                  Operator
highlight default link xdcTimingConstraints                    Operator
highlight default link xdcLogicAssignments                     Operator
highlight default link xdcObjectAccessCommands                 Operator
highlight default link xdcGeneralPurposeCommands               Operator
highlight default link xdcFloorplanCommands                    Operator
highlight default link xdcPowerCommands                        Operator
highlight default link xdcPinPlanningCommands                  Operator

highlight default link xdcConstant                             Constant
highlight default link xdcProperty                             Type

highlight default link xdcFlags                                Special

let b:current_syntax = "xdc"
