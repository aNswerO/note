for i in {1..9};do
	for j in `seq $i`;do
		echo -e ""$i"x"$j"=$((i*j))\t\c"
	done
	echo
done
