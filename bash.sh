#!/bin/bash

# author: timforgach@gmail.com
# params: external .csv file
# output: projects.json & filestructure with individual project.json files

# set some generic variables
countVar=1
urlString=null
dirPath=null

# if projects.json exists, delete it
[[ -d projects.json ]] || rm projects.json

# start of json structure
echo '{
	"projects": [' >> _projects.json

# read xls columns
while IFS=, read -r col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11
do
		# structure some data and store as variables
		xml=${col6}_${col7}
    filenameonly="${col6%.*}"
		now="$(date +'%d%m%Y')"
		echo "$col2 | $col3 | $col6"

		# if vpaid ad, then use url string
		if [ "$col9" == 'vpaid' ]; then
			urlString="https://tm-promo.s3.amazonaws.com/web/$col6/$col7/$col8/$xml.xml"
		else
			urlString=null
		fi

		# echo json structure
    json='
        {
              "url": "'$col1'",
              "clientName": "'$col3'",
              "template": "'$col2'",
              "format": "'$col9'",
              "features": "'$col4'",
              "vertical": "'$col5'",
              "sort": '$countVar',
              "key": '$countVar',
              "show": true,
              "projectId": "'$col6'",
							"creativeId": "'$col7'",
							"buildId": "'$col8'",
              "vastURL": "'$urlString'",
              "blurb": "'$col10'",
              "ctaURL": "'$col11'",
              "dateAdded": "'$now'"
        }'

        echo "$json ," >> _projects.json;

				# counter incriment
        countVar=$((countVar + 1))

  # if mraid ad
	if [ "$col9" == 'mraid' ]; then
		col9="mraid/projects"
	fi

	# make filestructure
  sudo mkdir -p ./$col9/$filenameonly

	# if filestructure exists, delete
	[[ -d ./$col9/$filenameonly/project.json ]] || rm ./$col9/$filenameonly/project.json

	# echo json structure
  echo '{
					"project": [' >> ./$col9/$filenameonly/project.json;
	echo $json >> ./$col9/$filenameonly/project.json;
	echo ']
}' >> ./$col9/$filenameonly/project.json;

# read from comma separated sheet
done < source.csv

echo '	]
}' >> _projects.json

# find and replace / work around for csv issue
cat _projects.json | sed -e 's/"null"/null/g' > __projects.json
rm _projects.json

cat __projects.json | sed -e "s/,]}/]} /g" > ../projects.json
rm __projects.json
