add_file_target(FILE Murax.v_toplevel_system_ram_ram_symbol0.bin)
add_file_target(FILE Murax.v_toplevel_system_ram_ram_symbol1.bin)
add_file_target(FILE Murax.v_toplevel_system_ram_ram_symbol2.bin)
add_file_target(FILE Murax.v_toplevel_system_ram_ram_symbol3.bin)

add_file_target(FILE hx8k_b_evn_toplevel.v SCANNER_TYPE verilog)
add_file_target(FILE Murax.v SCANNER_TYPE verilog)
add_file_target(FILE basys3_toplevel.v SCANNER_TYPE verilog)
add_file_target(FILE hx8k-b-evn.pcf)
add_file_target(FILE basys3.pcf)

if (NOT DEFINED ENV{CI} OR NOT $ENV{CI})
add_fpga_target(
  NAME murax
  BOARD hx8k-b-evn
  TOP toplevel
  SOURCES
    hx8k_b_evn_toplevel.v
    Murax.v
  INPUT_IO_FILE hx8k-b-evn.pcf
  EXPLICIT_ADD_FILE_TARGET
)
add_fpga_target(
  NAME murax_basys
  BOARD basys3
  TOP toplevel
  SOURCES
    basys3_toplevel.v
    Murax.v
  INPUT_IO_FILE basys3.pcf
  EXPLICIT_ADD_FILE_TARGET
)
endif (NOT DEFINED ENV{CI} OR NOT $ENV{CI})

