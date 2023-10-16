#!/bin/bash

#It will put the first argument to the first_arg variable. We dont care about other args provided.
first_arg="$1"

#This will be useful when creating a table since we are allowed to provide as many fields as we want
total_args=$#

db_name=
max_line_length=39
max_line_length_without_stars=36
max_row_length=8
max_row_length_with_space=7
max_row_length_with_stars=9
max_rows=4
max_args_in_db_name=1

#the variable below is for while loop in columns creation
#max_number=0

# Function that will read field names from the second row in the file and return them in array
find_field_names(){
#TODO
#    read -ra fields_array <<< "$( awk 'NR==2 { print $0 }' FS='[ *]+'  ./$db_name)"
#    result=$( awk 'NR==2 {for ( i=1; i <= NF; i++) { printf "%s ", $i }} ' 'FS=[ *]+'  ./$db_name)
#    read -ra fields_array <<< "$(echo -e "$result")"    
#    echo "${#fields_array[@]} ovo je array"
    
    IFS=' *' read -ra fields_array <<< $( awk 'NR==2' ./$db_name)
#    IFS=' *' read -ra fields_array <<< "$( awk 'NR==2 {for ( i=1; i <=NF; i++) {printf "%s ", $i }} ' ./$db_name)"
    echo "${fields_array[@]}"
}
: '
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
            rm -rf ./$db_name
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
'

#Function for creating field names in db, it sets first two names as mandatory fields, allows us to have up to 4 field names(columns). Then it calls validate length
create_table(){
#    max_number=0
#    all_passed=0
#    while [ $max_number -eq 0 ]
    while true;
    do
        echo "Input the field names (example: id name height age)"
    	echo "*First two field names will be created as mandatory fields!"
	echo "*First field will be set as unique field!" 
	read -a FIELDNAMES

	
    
    	fields_number=${#FIELDNAMES[@]}    
    	if (($fields_number > $max_rows ));
    	then
        	echo "The maximum number of columns is $max_rows."
        	echo "Try again."
    	else
            col_list=("${FIELDNAMES[@]}")
	    validate_length "${#FIELDNAMES[@]}" "${col_list[@]}" "${FIELDNAMES[@]}"
        fi 
    done
}

#Function that will check the length of every field name or its value, if it exceedes allowed length then it calls back create_table or insert_data. If everything is okay then populate_table will be called

validate_length(){
#using $@ we are taking the passed arg to field_names variable, $@ to preserve empty elements
#   it will store every argument provided starting from $1(which is length of the array) plus two, so if $1(length) is 4 it will skip first 4 args plus 2, and it will store everything starting from 6st arg
#   because at the 6st arg starts the array that we need in this variable
    field_names=("${@:$1+2}")
#   this will store every arg starting from second (first is $1 which represents length of the array). col_list arg has exactly the same num of args as fieldnames and it will store everything from the second#   argument @ means all 2 means starting arg and $1 means last arg
    col_list=("${@:2:$1}")

    for ((i=0;i < ${#field_names[@]};i++));
    do
        if (( ${#field_names[$i]} > $max_row_length_with_space ));
	then    
	    echo "Maximum number of characters for field names is $max_row_length_with_space."
#	    echo "${field_names[$i]} vs ${col_list[$i]}"
	    if [ ${field_names[$i]} == ${col_list[$i]} ];
	    then
		sleep 0.3
		echo "Redirecting back to table columns creation.."
		sleep 0.6
	        create_table
	    else
		sleep 0.3
		echo "Redirecting back to data insert.."
		sleep 0.6
   		insert_data
	    fi             
	fi
    done
#    ((max_number++))
    populate_table "${field_names[@]}"
}

# Function populate table will simply take all fields, add stars and spaces needed and then write it to the file

populate_table() {
    new_col=""
    args_list=("$@")
    new_line=""   
    
    new_col="*"
    for ((i=0;i<${#args_list[@]};i++))
    do
        diff=$max_row_length_with_space-${#args_list[$i]}
    	new_line+="* ${args_list[$i]}"
    	for ((j=0;j < $diff;j++));
    	do
       	    new_line+=" "
    	done
        
    done

    if (("${#new_line}" < $max_line_length_without_stars ));
    then
        for ((i="${#new_line}"; i < $max_line_length_without_stars; i++));
        do
	    new_line+=" "
	done
    fi
    new_col+=$new_line
    echo "Updating table.."
    sleep 0.7
    new_col+="**"
    echo "${new_col}" >> ./$db_name
    echo "Table is successfully updated!"
    cat ./$db_name

# this will call function that will get us column names
#    find_field_names
    table_menu

}

create_table_header(){
    header_stars=""
    for ((i=0; i < $max_line_length;i++));
    do
        header_stars+="*"
    done
    echo "$header_stars" >> ./$db_name

}

#Function for table menu, it will loop always and get us through functionalities

table_menu(){

    sleep 0.5

    while true
    do
    
        echo "Loading table menu options.."
    	sleep 0.5
    	echo "|---------------------|"
    	echo "  1. Insert data"
    	echo "  2. Select data"
    	echo "  3. Delete data"
    	echo "  4. Show table"
    	echo "  5. Exit"
    	echo "|---------------------|"
    	printf "Choose from the list: "
    	read TABLEMENU

    	case $TABLEMENU in
        
            1)
	        insert_data
	    ;;         
            2)
	        select_data "Read"
            ;;
            3)
	        select_data "Delete"
            ;;
	    4)
	        cat ./$db_name
	    ;;
 	    5)
	        exit
	    ;;
	    *)
	        echo "Not an option. Try again!"
	    ;;
        esac
        done
}

# Function select data gives us manu for read or delete options, it is dynamically populated with names of fields by function find_field_names

select_data(){
    col_list=($(find_field_names))
    read_or_delete=$1
    echo "You have entered $read_or_delete data mode, loading options.."
    sleep 0.4
    echo "|---------------------|"
    echo "  1. $read_or_delete all data"
    for (( i=0; i < ${#col_list[@]};i++ ));
    do
        echo "  "$((i+2))". $read_or_delete by ${col_list[$i]}"
    done
    echo "|---------------------|"
    printf "Choose from the list: "
    read READMENU

    case $READMENU in

    1)
	if [[ $read_or_delete == "Read" ]];
        then
            cat ./$db_name
	else
	    awk 'NR<=2' ./$db_name | sponge ./$db_name
	    sleep 0.3
	    echo "Table data is successfully deleted!"
	fi
    ;;

    2)
	printf "Insert the ${col_list[0]}: "
	read id_read
        read_delete "${col_list[0]}" "$id_read" "$read_or_delete"
    ;;
    
    3)
	printf "Insert the ${col_list[1]}: "
	read id_read
        read_delete "${col_list[1]}" "$id_read" "$read_or_delete"
    ;; 

    4)
	printf "Insert the ${col_list[2]}: "
	read id_read
        read_delete "${col_list[2]}" "$id_read" "$read_or_delete"
    ;;
    
    5)
	printf "Insert the ${col_list[3]}: "
	read id_read
        read_delete "${col_list[3]}" "$id_read" "$read_or_delete"
    ;;

    *)
	echo "Not an option. Try again!"
    ;;
    esac

}

# Function existance_check will get us information does provided value exists in the db

existance_check(){
    
    search_by_arg=$1
    value=$2

    column_index=$(awk -v name="$search_by_arg" '{ for (i=1; i<=NF;i++) { if ($i == name) { print i; exit } } }' FS='[ *]+' ./$db_name)  
    result="$(awk -v col="$column_index" -v val="$value" '$col == val' FS='[ *]+' ./$db_name)"
    echo "$result"
    
}

# Function read_delete is used to depends on selected read or delete show us rows by selected column name or delete them

read_delete(){
    search_by_arg="$1"
    value="$2"
    read_or_del="$3"
    input_file="$db_name"

    column_index=$(awk -v name="$search_by_arg" '{ for (i=1; i<=NF;i++) { if ($i == name) { print i; exit } } }' FS='[ *]+' ./$db_name) 
    echo "$column_index col index iz read delete" 
#    result="$(awk -v col="$column_index" -v val="$value" '$col == val' FS=' ' ./$db_name)"

    result=$(existance_check "$search_by_arg" "$value") 
    if [ -z "$result" ];
    then
        sleep 0.3
	echo "Provided $search_by_arg does not exists in database!"
	sleep 0.3
    else

        if [[ $read_or_del == "Read" ]]
        then
#           this awk checks if the val variable value exists in the $col column provided by awk column_index and prints it
#        result="$(awk -v col="$column_index" -v val="$value" '$col == val' FS=' ' ./$db_name)"
	    awk 'NR <= 2' ./$db_name
	    echo "$result"
        else
#           this awk checks does column provided has the value provided, all != will be sponged and == will be removed
 	    awk -v value="$value" -v col="$column_index" '$col != value' FS='[ *]+'  ./$db_name | sponge ./$db_name
	    sleep 0.3
            echo "Successfully deleted!"
#            cat ./$db_name
	fi
    fi
#   NR=1 umesto NR==1 setuje 1 za svaku liniju umesto da odradi samo prvu liniju? 
#   NF je koliko ima kolona u odredjenom redu
#   -F' ' specifies that the field separator is space
#   NR <= 2 will print first two lines from the file
#   $2 represents the position of the second column, we separated row by spaces
#   awk -v value="$search_by_arg" -F' ' 'NR <= 2 || { for (i = 1; i <= NF; i++) if ($i == value) { print; break} }' ./$db_name 
}

# Function insert_data will get all the inputs from user to insert a new row, it will check for mandatory fields not to be empty or first value uniqueness

insert_data(){
    
    col_list=($(find_field_names))
    insert_list=()
    echo "You are entering insert mode.."
    for ((i=0; i < ${#col_list[@]}; i++));
    do	
	
	while true
	do

            printf "Insert the ${col_list[$i]} value: "
    	    read line
	    if [[ $i -eq 0 || $i -eq 1 ]];
	    then
	        if [ -z $line ];
	   	then
		    echo "Mandatory fields: ${col_list[0]} and ${col_list[1]} cannot be empty!"
		    i=0
	   	else
		    if [[ $i -eq 0 ]];
		    then
		        result=$(existance_check "${col_list[0]}" "$line")
 		    	if [[ -z $result ]];
		    	then
	       	            insert_list+=("$line")
	   	            break
		        else
		  	    echo "Provided ${col_list[$i]} already exists!"
		        fi
		    else
			insert_list+=("$line")
			break
		    fi
                fi
	    else
	    	if [ -z $line ];
	    	then
		    insert_list+=(" ")
		    break
	    	else
		    insert_list+=("$line")
		    break
	    	fi
	    fi
	done
    done
    validate_length "${#insert_list[@]}" "${col_list[@]}" "${insert_list[@]}"
}

create_table_selection() {   
    counter=0
    while [ $counter -eq 0 ]
    do
        echo "|---------------------|"
        echo "  1. Create database"
	echo "  2. Modify database"
        echo "  3. Cancel"
    	echo "|---------------------|"
    	printf "Choose from the list:"
    	read -r SELECTION
   
    	case $SELECTION in
    
    	1)
	    printf "Insert the database name: "
	    read -a DB_NAME
	    if (( "${#DB_NAME[@]}" > $max_args_in_db_name ));
	    then
		echo "Invalid database name! Try again!"
		sleep 0.4
	    else
	        ((counter++))
            	create_db "${DB_NAME[0]}"
	    fi
    	;;

	2)
	    printf "Insert the database name: "
	    read table_read
	    if [[ -e "$table_read" ]];
	    then
		extension="${table_read##*.}"
		if [ "$extension" = "database" ];
		then
	            db_name=$table_read
		    table_menu
		else
		    sleep 0.3
		    echo "Not supported file. Try with another one!"
		    sleep 0.3
		fi
		
	    else
		echo "Database does not exist!"
		sleep 0.5
#		$db_name=$table_read
#		table_menu
	    fi
	;;
    
    	3)
#            cancel_table_creation
	    exit
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
#  this variable stores the db name inserted by user in create_table_selection and passed as an arg to this func
#    db_name=$1
 
    db_name=$1.database
    

    echo "Creating database.."
    sleep 0.5
    echo "Provided database name: $db_name"
    sleep 0.8
    if ! test -f ./$db_name
    then
      touch $db_name
      echo "Database: $db_name is successfully created."
      create_table_header
      create_table
#      create_table_selection
    else
      echo "Database could not be created, file with provided name already exists in current directory!"
    fi
}
create_table_selection
#if [ $total_args -eq 0 ]
#then
#    echo "There is no arguments provided, could not create database."
#else
#    create_db
#fi
