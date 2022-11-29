#!/usr/bin/env bash

# using colors: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
Color_Off='\e[0m'       # Text Reset
BWhite='\e[1;37m' 
BGreen='\e[1;32m'
BRed='\e[1;31m'
BCyan='\033[1;36m'
BBlue='\e[1;34m'
BYellow='\e[1;33m'
Purple='\e[0;35m'

# accepting an optional argument, consisting on the folder to search
dir=$1

# initializing some variables 
total_number_of_sequences_in_files=0
total_length_of_sequences_in_files=0

# create an array of all fa/fasta files and symlinks 
array=( $(find $dir -not -path '*/.*' -type f,l -name "*fasta" && find $dir -not -path '*/.*' -type f,l -name "*.fa") )

# count file into nfiles
nfiles=${#array[@]}

# if there's no file of interest
if [[ $nfiles -eq 0 ]]
  then 
    printf "$Red No fa/fasta files present in the given folder.$Color_Off"
    exit
fi

# let's initialize the report
echo "Processed data of all .fasta and .fa files found:"

for file_path in ${array[@]}
do

  # print path of the file
  printf "\n$BWhite$file_path$Color_Off"

  if [[ -L $file_path ]]
    then
      # path leads to a symbolic link
      printf " -$BBlue Symlink$Color_Off"
  else
      # path leads to a file
      printf " -$BGreen File$Color_Off"
  fi

  if ! [[ -s $file_path ]]
    then
      # file is empty 
      printf " -$BRed Empty$Color_Off\n"
      continue
  else
      # omit the titles and remove all whitespace
        # characters (including line break) and punctuation (and symbols)
      filtered=$(awk '!/>/ {gsub(/[[:space:]]/,""); gsub(/[[:punct:]]/,""); printf "%s", $1}' $file_path)
      if [[ $filtered =~ ^[ATCGNatcgn]*$ ]]
        then
             # file only contain the characters inside [], 
              # so contain nucleotides
            printf " -$BYellow Nucleotide$Color_Off\n"
        else
            # file contain other characters that are not inside [], 
              # so contain proteins
            printf " -$BCyan Protein$Color_Off\n"
      fi

      # count number of sequences in file
      number_of_sequences_in_file=$(grep -c ">" $file_path)
       echo -e "\tThe file contains $number_of_sequences_in_file sequences."
      # count total number of sequences in files
      ((total_number_of_sequences_in_files=total_number_of_sequences_in_files+number_of_sequences_in_file))

      # count length of sequences in file
      length_of_sequences_in_file=$(awk '!/>/ {gsub(/[[:space:]]/,""); gsub(/[[:punct:]]/,""); seqlen += (length($0))} END {print seqlen}' $file_path)
       echo -e "\tThe length of all sequences in the file is $length_of_sequences_in_file."
      # count total length of all sequences in files
      ((total_length_of_sequences_in_files=total_length_of_sequences_in_files+length_of_sequences_in_file))

  fi
done

# print total number of sequences in files
printf "\nThe total number of sequences in the files is $total_number_of_sequences_in_files.\n"  
# print total length of all sequences in files
printf "The total length of all sequences is $total_length_of_sequences_in_files.\n"

# print a single title
printf "\nAn example of a title: \"$Purple$(awk '{print}' "${array[@]}" | egrep -m 1 "^>")$Color_Off\"\n\n"

