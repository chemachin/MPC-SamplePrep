###########################String‑trimming tips###############################
# everything after the first slash:
#echo "${var#*/}"
# everything after the last slash:
#echo "${var##*/}"
# everything before the first slash:
#echo "${var%%/*}"
# everything before the last slash:
#echo "${var%/*}"

"""
Checks folder names exceeding FOLDERTAM length
"""
function NumCaracteresFolder () {
	find $1 -type d -print0 |         
	while IFS= read -r -d '' file; do
        	path="${file:${#1}}" # For ‘file’, strip ruta($1) because has no spaces

		# Checks character length
		lastslash="${path##*/}"	# Keeps only the last level of each directory, everything after the final slash (/)
        	if [ ${#lastslash} -ge $FOLDERTAM ]; then
                	echo "$path" >> renamefolders.log
			echo "$lastslash --> ${#lastslash}" >> renamefolders.log
			echo "******************************" >> renamefolders.log
        	fi

	done
}

"""
Checks WAV filenames exceeding FILETAM length (spaces excluded)
Flow: find WAVs → escape spaces → trim extension → count non-space chars
"""
function NumCaracteresFile () {
	# TODO: Find a way to escape the & character (and other special characters), otherwise the find command below throws an error
	find $1 -type f -iname '*.wav' -print0 |
	while IFS= read -r -d '' file; do
        	# Whitespace characters are replaced with \  to allow reaching directories whose names contain spaces
        	sample="${file//" "/\ }"
		# Trims the sample name (without the extension) and check its character length
		name=$(echo "$sample" | rev | cut -d'/' -f-1 | rev | cut -d'.' -f-1)
		#echo "${#name}" # This counts the number of characters in the variable
		res="${name//[^\ ]}"    # Stores whitespace characters in the variable
		tam=$((${#name} - ${#res})) # Subtract the number of spaces from the filename length
		if [ $tam -ge $FILETAM ]; then
			echo "$sample --> $tam" >> renamefiles.log
                        echo "******************************" >> renamefiles.log
		fi
	done
}

"""
Normalizes WAV files to 44.1kHz/16-bit, logs issues to badfiles.log
Creates RS_ prefixed copies in same directory when processing needed
"""
function ProcessAudio (){
    # TODO: Find a way to escape the & character (and other special characters), otherwise the find command below throws an error
    find $ruta -type f -iname '*.wav' -print0 |
    while IFS= read -r -d '' file; do
        # Whitespace characters are replaced with \  to allow reaching directories whose names contain spaces
        sample="${file//" "/\ }"
        #echo "--> $sample"
        # Soxi command checks that the sample rate is 44100, and stores the output in the out variable
        out=$(eval "$(echo "./sox --i -r $sample")")
        # If case of error, store the path in badfiles.txt
        if [ $? -ne 0 ]; then
                echo "$sample" >> badfiles.log
        fi
        # If the sample rate isn't 44100, we process it and also set the encoding to 16-bit
        if [ $out -gt 44100 ]; then
                echo "$sample" >> resamplefiles.log
        	dirname=${sample%/*}
                name=$(echo "$sample" | rev | cut -d'/' -f-1 | rev)
                newsample="$dirname/RS_$name"
                eval "$(echo "./sox $sample -b 16 $newsample")"  
	fi
        # Soxi checks that the encoding is 16-bit, and stores the output in the out variable
        out=$(eval "$(echo "./sox --i -b $sample")")
        # If case of error, store the path in badfiles.txt
        if [ $? -ne 0 ]; then
                echo "$sample" >> badfiles.log
        fi
        # If the encoding isn't 16-bit, we process it
        if [ $out -gt 16 ]; then
                echo "$sample" >> resamplefiles.log
		dirname=${sample%/*}
		name=$(echo "$sample" | rev | cut -d'/' -f-1 | rev)
		newsample="$dirname/RS_$name"
                eval "$(echo "./sox $sample -b 16 $newsample")" 
        fi
done
}

#****************************************MAIN*************************************
# This path must go without whitespace characters
ruta="/Users/chema/Desktop/MPC-Samples"
FOLDERTAM=17
FILETAM=17
option=1

while [ $option -ne 4 ]; do
	echo `clear`
	echo "*******************MENU*******************"
	echo "1.- Check folder length"
	echo "2.- Check file length"
	echo "3.- Change sample rate and encoding (44100 Hz - 16 bits)"
	echo "4.- Exit"
	echo ""
	printf 'You choose : '
	read option

	if [ $option -eq 1 ]; then
		NumCaracteresFolder "$ruta"
		echo "***********************************"
		echo "Check log @ renamefolders.log"
	fi
	if [ $option -eq 2 ]; then
		NumCaracteresFile "$ruta"
		echo "***********************************"
		echo "Check log @ renamefiles.log"
	fi
	if [ $option -eq 3 ]; then
		ProcessAudio
		echo "***********************************"
		echo "Check log @ resamplefiles.log and badfiles.log"
	fi
	if [ $option -eq 4 ]; then
		exit
	fi

	printf 'Press enter to continue: '
	read go
	
done
exit
