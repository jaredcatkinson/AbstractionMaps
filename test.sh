#!/usr/bin/env bash

for map in $(find ./content -name 'map.html') 
        do  
        	index_file="/index.html"
        	echo $map
	    	directory=$(dirname "$map")
            index=$directory 
            echo $index
            index_content="$index$index_file"
            echo $index_content
            final_index="$(echo $index_content | sed 's/content/public/g')"
            echo $final_index
            map_html=$(cat $map)
            echo $map_html
            sed -i "s/$map_html/MAP GOES HERE/g" "$final_index"
            cat $final_index

        done 
