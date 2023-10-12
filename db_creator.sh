#!/bin/bash

#It will put the first argument to the first_arg variable. We dont care about other args provided.
first_arg="$1"

#This will be useful when creating a table since we are allowed to provide as many fields as we want
total_args=$#

creation_menu_selected=0
max_line_length=39
max_row_length=8
max_row_length_with_space=7
max_row_length_with_stars=9
max_rows=4

col_list=()

cancel_table_creation(){
    selected=0
    while [ $selected -eq 0 ]
    do
        echo "By cancelling the process the created db file will be deleted since it is empty."
        printf "Do you want to proceed?(y/n):"
        read -r DELETESELECT

        case $DELETESELECT in

        y)
            echo "Aborting table creation.."
            sleep 0.5
            rm -rf ./$first_arg
            echo "Database file is deleted."
            ((selected++))
	    ((creation_menu_selected++))
        ;;

        n)
            echo "Getting back to table creation menu.."
            sleep 0.5
            ((selected++))
        ;;

        *)
            echo "Not like that. Please select a valid option."
            sleep 0.8
        ;;
        esac
    done
}

#Function for table creating
create_table(){
    max_number=0
    all_passed=0
    while [ $max_number -eq 0 ]
    do
        echo "Input the field names (example: id name height age)"
    	read -a FIELDNAMES
    
    	fields_number=${#FIELDNAMES[@]}    
    	if (($fields_number > $max_rows || $fields_number < $max_rows));
    	then
        	echo "The required number of rows is $max_rows."
        	echo "Try again."
    	else
#	    col_list=()
            for ((i=0;i < $fields_number;i++));
	    do
	        if (( ${#FIELDNAMES[$i]} > $max_row_length_with_space ));
	    	then    
		    echo "Maximum number of characters for field names is $max_row_length_with_space."
		    ((all_passed++))
		    col_list=()
		    break
		else
		    col_list+=(${FIELDNAMES[$i]})
		fi
            done
	if [[ $all_passed -eq 0 ]];
	then 
	    ((max_number++))
	    create_table_header
	else
            ((all_passed--))
	fi
    	fi
    done
    echo "lista prvi put ${col_list[@]}"
    populate_table "${col_list[@]}"
}

populate_table() {
    new_col=""
    args_list=("$@")
    new_line=""   
    
    echo "prvi print populejta ${args_list[@]}"
    new_col="*"
    for ((i=0;i<${#args_list[@]};i++))
    do
	echo "print iz populejta ${args_list[$i]}"
        diff=$max_row_length_with_space-${#args_list[$i]}
    	new_line+="* ${args_list[$i]}"
    	for ((j=0;j < $diff;j++));
    	do
       	    new_line+=" "
    	done
        
    done
    new_col+=$new_line
    echo "Creating table.."
    sleep 0.7
    new_col+="**"
    echo "${new_col}" >> ./$first_arg
    echo "Table is successfully created!"
    cat ./$first_arg

    table_menu

}

create_table_header(){
    header_stars="*"
    for ((i=0; i < $max_line_length;i++));
    do
        header_starts+="*"
    done
    echo "$header_starts" >> ./$first_arg

}

table_menu(){

    sleep 0.5
    
    echo "Loading table menu options.."
    sleep 0.7
    echo "|---------------------|"
    echo "  1. Insert data"
    echo "  2. Select data"
    echo "  3. Delete data"
    echo "|---------------------|"
    printf "Choose from the list:"
    read TABLEMENU

    case $TABLEMENU in
        
        1)
	    insert_data
	;;         
        2)
	    select_data
        ;;
        3)
	    delete_data
        ;;

    esac

}

insert_data(){
    insert_list=()
    echo "You have entered inserting mode, follow the instructions!"
    echo "${#col_list[@]}"
    
    for ((i=0; i < ${#col_list[@]}; i++));
    do
        printf "Insert the ${col_list[$i]} value: "
        read value
        insert_list+=($value)
    done
    echo "printam insert listu ${insert_list[@]}"
    populate_table "${insert_list[@]}"
}

create_table_selection() {
    while [ $creation_menu_selected -eq 0 ]
    do
        echo "|---------------------|"
        echo "  1. Create a table"
        echo "  2. Cancel"
    	echo "|---------------------|"
    	printf "Choose from the list:"
    	read -r SELECTION
   
    	case $SELECTION in
    
    	1)
            create_table
	    ((creation_menu_selected++))  
    	;;
    
    	2)
            cancel_table_creation
    	;;
    
    	*)
            echo "Please select a valid option"
            sleep 0.5
    	;; 
    	esac
    done
}

#Function that will create a db(file) with provided name
create_db() {
    echo "Creating database.."
    sleep 0.5
    echo "Provided database name: $first_arg"
    sleep 0.8
    if ! test -f ./$first_arg
    then
      touch $first_arg
      echo "Database: $first_arg is successfully created."
      create_table_selection
    else
      echo "Database could not be created, file with provided name already exists in current directory!"
    fi
}

if [ $total_args -eq 0 ]
then
    echo "There is no arguments provided, could not create database."
else
    create_db
fi