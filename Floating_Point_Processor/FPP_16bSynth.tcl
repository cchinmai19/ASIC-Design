
########################
## Setup variables #####
########################

## RTL files to be loaded
set FILE_LIST {FPP_16Bit.v}

## Top-level cell
set MODULE {FPP_16b}


set_attribute lib_search_path /home/seas/grad/cchinmai/cadence/RTL

## Set location to search for HDL files 
set_attribute hdl_search_path /home/seas/grad/cchinmai/cadence/Final_Project/

## This defines the standard cell libraries to use
set_attribute library {ami035stdcell.lib}

set_attribute hdl_vhdl_environment common

##This must point to your VHDL/verilog file
##it is recommended that you put your VHDL/verilog in a folder called HDL in
##the directory that you are running RC out of
## CHANGE THIS LINE to your VHDL/verilog file name
##read_hdl -vhdl ./HDL/$FILE_LIST
read_hdl $FILE_LIST

## This builds the general block
elaborate $MODULE

##this allows you to define a clock and the maximum allowable delays
## READ MORE ABOUT THIS SO THAT YOU CAN PROPERLY CREATE A TIMING FILE
# defines a clock called 'Clk' than runs at 1MHz
set clock [define_clock -period 1000000 -name Clk]
#external delay -input 300 -edge rise clk
#external delay -output 2000 -edge rise p1

##This synthesizes your code
synthesize -to_mapped

## This writes all your files
## change the tst to the name of your top level verilog
## CHANGE THIS LINE: THIS FILENAME YOU WILL NEED IT WHEN SETTING UP THE PLACE & ROUTE
write -mapped >$MODULE.v

## THESE FILES ARE NOT REQUIRED, THE SDC FILE IS A TIMING FILE
write_script > scriptTest

##write sdc > test.sdc
