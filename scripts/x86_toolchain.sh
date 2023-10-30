#!/bin/bash


# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

# Annotations by:
# Sam Cordara
# ITSC-204, ISS, SAIT
# October 2023


if [ $# -lt 1 ]; then
# this checks if the number of command-line arguments is less than 1
# $# is a variable that holds the number of arguments passed to the script


    echo "Usage:"
    echo ""
    echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
    echo ""
    echo "-v | --verbose                Show some information about steps performed."
    echo "-g | --gdb                    Run gdb command on executable."
    echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
    echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
    echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
    echo "-64| --x86-64                 Compile for 64bit (x86-64) system."
    echo "-o | --output <filename>      Output filename."
    # prints a usage message explaining how to run the script with various options
   
    exit 1
    # exits with status code 1, indicating an error
fi

POSITIONAL_ARGS=()
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS=False
QEMU=False
BREAK="_start"
RUN=False
# these lines initialize various variables used in the script


while [[ $# -gt 0 ]]; do
# this loop goes through each command line argument (using the shift command) until the number of arguments ($#) is not greater than 0


    case $1 in
    # this is a case statement that checks the value of the argument in the current loop iteration
   
        -g|--gdb)   # if the value is'-g' or '--gdb' it changes the GDB variable value to true
            GDB=True
            shift # past argument
            ;;    # end of case clause
        -o|--output)    # if the value is '-o' or '--output' it changes value of 'OUTPUT_FILE' to '$2', where the new output file is expected to be provided
            OUTPUT_FILE="$2"
            shift # past argument
            shift # past value
            ;;
        -v|--verbose)   # if the value is '-v' or '--verbose' it changes the 'VERBOSE' variable value to true
            VERBOSE=True
            shift # past argument
            ;;
        -64|--x84-64)   # if the value is '-64' or '--x86-64' it changes the BITS variable value to true
            BITS=True
            shift # past argument
            ;;
        -q|--qemu)  # if the value is '-q' or '--qemu' it changes the QEMU variable value to true
            QEMU=True
            shift # past argument
            ;;
        -r|--run)   # if the value is '-r' or '--run' it changes the RUN variable value to true
            RUN=True
            shift # past argument
            ;;
        -b|--break) # if the value is '-b' or '--break' it changes the BREAK variable value to '$2' or argument 3
            BREAK="$2"
            shift # past argument
            shift # past value
            ;;
        -*|--*)     # if the value is anything else it will print the following echo to the terminal
                    # with the argument of the unknown option
            echo "Unknown option $1"
            exit 1  # exits the process with status code 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional argument by appending it to an array
            shift # discard positional argument
            ;;
    esac    # end of the case statement
done    # end of the loop

set -- "${POSITIONAL_ARGS[@]}"  # sets the positional parameters to the values stored in the variable 'POSITIONAL_ARGS'

if [[ ! -f $1 ]]; then
                        # checks if the first positional argument is a file or not
                        # ! is the negation operator, and -f checks if a file exists


    echo "Specified file does not exist"
    exit 1
                        # if no file with the given name is found, the echo is printed to terminal,
                        # then the process is exited with staus code 1
fi


if [ "$OUTPUT_FILE" == "" ]; then   # checks if OUTPUT_FILE is an empty string

    OUTPUT_FILE=${1%.*}   # if so, it sets OUTPUT_FILE to the input file name with the extension removed
fi

if [ "$VERBOSE" == "True" ]; then   # checks if VERBOSE is set to 'True'

    echo "Arguments being set:"
    echo "    GDB = ${GDB}"
    echo "    RUN = ${RUN}"
    echo "    BREAK = ${BREAK}"
    echo "    QEMU = ${QEMU}"
    echo "    Input File = $1"
    echo "    Output File = $OUTPUT_FILE"
    echo "    Verbose = $VERBOSE"
    echo "    64 bit mode = $BITS"
    echo ""
    # if the verbose option is chosen, it prints values of the various options and what they are set to

    echo "NASM started..."
fi


if [ "$BITS" == "True" ]; then  # checks if BITS is set to true

    nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""
    # if the bits option is chosen, it assembles the input file using the nasm assembler for 64-bit systems


elif [ "$BITS" == "False" ]; then   # checks if BITS is still set to false


    nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""
    # if so, it assembles the input file using the nasm assembler for 32-bit systems
fi


if [ "$VERBOSE" == "True" ]; then   # also checks if VERBOSE is set to 'True'


    echo "NASM finished"
    echo "Linking ..."
fi  # if so, it prints the following echo statements


if [ "$BITS" == "True" ]; then  # this also checks if BITS is set to 'True'


    ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""
    # if so, it links the object file using the ld linker for 64-bit systems

elif [ "$BITS" == "False" ]; then   # checks if BITS is set to 'False'


    ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""
    # if so, it links the object file using the ld linker for 32-bit systems
fi


if [ "$VERBOSE" == "True" ]; then   # also checks if VERBOSE is set to 'True'


    echo "Linking finished"
fi
# if so, it prints information about the script's state when linking is complete


if [ "$QEMU" == "True" ]; then  # this checks if QEMU is set to 'True'


    echo "Starting QEMU ..."
    echo ""
# if so, it prints these echo statements.


    if [ "$BITS" == "True" ]; then  # also checks if BITS is set to 'True'

        qemu-x86_64 $OUTPUT_FILE && echo ""
        # if so, it runs the executable using the QEMU emulator for 64-bit systems

    elif [ "$BITS" == "False" ]; then   # checks if BITS is set to 'False'


        qemu-i386 $OUTPUT_FILE && echo ""
        # if so, runs the executable using the QEMU emulator for 32-bit systems
    fi

    exit 0  # this exits the script with status code 0, indicating successful execution
fi  

if [ "$GDB" == "True" ]; then   # check if the variable GDB is set to 'True'

	gdb_params=()   # initializes an array called gdb_params
    gdb_params+=(-ex "b ${BREAK}")  # adds a GDB command to set a breakpoint at the location specified by BREAK

	if [ "$RUN" == "True" ]; then   # check if the variable $RUN is set to "True"

		gdb_params+=(-ex "r")   # if RUN is true, add a GDB command to run the program

	fi

	# runs GDB with the prepared parameters and $OUTPUT_FILE as an argument
	gdb "${gdb_params[@]}" $OUTPUT_FILE

fi 