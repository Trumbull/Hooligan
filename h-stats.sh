gpu_stats=`timeout -s9 60 gpu-stats`
gpu_stats_json="/run/hive/gpu-stats.json"
nvidia_indexes_array=`echo /run/hive/gpu-stats.json | jq -c '[ . | to_entries[] | select(.value.brand == "nvidia") | .key ]'`

get_cards_hashes(){
	hs=''	

	#let hs=$h/$GPU_COUNT_AMD
		for (( i=0; i < ${GPU_COUNT_AMD}; i++ )); do
		local s=`cat $LOG_NAME| tail -n 20 |grep -i "hash"| tail -n 1 | cut -c 11-14 | awk '{printf $1}'`
		local t=0
		let t=$s/$GPU_COUNT_AMD
		hs[$i]=$t
	done
}

get_total_hashes(){
	local Total=`cat $LOG_NAME| tail -n 20 |grep -i "hash"| tail -n 1 | cut -c 11-14 | awk '{printf "%.0f\n",$1*1000}'`
	echo $Total
}

get_amd_cards_temp(){
	echo $(jq -c "[.temp$amd_indexes_array]" <<< $gpu_stats)
}

get_amd_cards_fan(){
	echo $(jq -c "[.fan$amd_indexes_array]" <<< $gpu_stats)
}

get_nvidia_cards_temp(){
        echo $(jq -c "[.temp$nvidia_indexes_array]" <<< $gpu_stats)
}

get_nvidia_cards_fan(){
        echo $(jq -c "[.fan$nvidia_indexes_array]" <<< $gpu_stats)
}

#######################
# MAIN script body
#######################
. /hive/miners/custom/bfgminer/h-manifest.conf
LOG_NAME="$MINER_LOG_BASENAME.log"

khs=0


[[ -z $GPU_COUNT_AMD ]] &&
	GPU_COUNT_AMD=`gpu-detect AMD`

#GPU stats
#gpu_detect_json=`gpu-detect listjson`
#amd_indexes_array=`echo "$gpu_detect_json" | jq -c '[ . | to_entries[] | select(.value.brand == "amd") | .key ]'`
#gpu_stats=`timeout -s9 60 gpu-stats`

# Calc log freshness


#hs=$(get_cards_hashes)
#temp=$(get_nvidia_cards_temp)	# cards temp
#fan=$(get_nvidia_cards_fan)	# cards fan
#hs_units='khs'				    # cards temp
#khs=`echo $stats_raw | jq 'MH/s' | awk '{print $1*1000}'`
#hs=`echo $stats_raw | jq -r '.stats.hs'`
#algo='sha224'	 # algo

#stats_raw=`cat /var/log/miner/HooliganMiner/HooliganMiner.log | sed 's/\"\[/\[/' | sed 's/\]\"/\]/'`
#cat /run/hive/gpu-stats.json | tail -1 | jq -r ".temp | .[]"
#	n=`cat $LOG_NAME | tail -n 20 | grep -n "MH/s" $LOG_NAME | awk '{print $1}'`
#	nt=`echo $n | awk '{ printf("%.f",$1) }'`
#	temp=`cat $gpu_stats_json | jq -c ".temp"` 
        temp=$(get_nvidia_cards_temp)
	fan=$(get_nvidia_cards_fan)	
	hs=129
	hs_units="Mhs"
	algo="x13"
	uptime=20
#	ac=`cat $LOG_NAME| tail -n 20 |grep -i "hash"| tail -n 1 | cut -c 37-39 | awk '{printf $1}'`
    ac=10
	rj=10	
	ver=7.0
	stats=$(jq -nc \
    --arg algo "$algo" \
    --argjson hs "$hs" \
    --arg hs_units "Mhs" \
    --argjson fan "$fan" \
    --argjson temp "$temp" \
    --arg bus_numbers "129" \
    --arg ver "$ver" \
    '{$hs, $hs_units, $temp, $fan, $bus_numbers, uptime:'$uptime', ar: ['$ac', '$rj'], $algo, $ver}')
	khs=130

# debug output
#echo ac:  $ac
echo fan:   $fan
#echo hs:    $hs
#echo nt:  $nt
echo stats: $stats
#echo khs:   $khs
