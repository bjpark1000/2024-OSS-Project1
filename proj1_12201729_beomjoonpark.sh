#!/bin/bash

if [ $# -ne 3 ] || [[ $1 != *".csv" ]] || [[ $2 != *".csv" ]] || [[ $3 != *".csv" ]]; then
echo "usage: $0 file1 file2 file3"
exit 1 # 0 means succeed
fi

team_file=$1
player_file=$2
match_file=$3

function print_player {
	awk -v player_name="$1" -F, '$1==player_name{print "Team:"$4",Apperance:"$6",Goal:"$7",Assist:"$8}' $player_file
}

function print_team {
	awk -v league_position="$1" -F, '$6==league_position{print $6, $1, $2/($2+$3+$4)}' $team_file
}

function print_top3_attendance {
	echo "***Top-3 Attendance Match***"
	echo

	sed -e 1d $match_file | sort -r -t ',' -n -k 2 | head -n 3 | awk -F, '{print $3" vs "$4" ("$1")"; print $2, $7"\n"}'
}

function print_top_scorer {
	IFS=$'\n'
	for team_line in $(sed -e 1d $team_file | sort -t ',' -n -k 6 | awk -F, '{print $6","$1}')
	do
		echo $team_line | sed -E 's/,/ /g'
		awk -v current_team="$(echo $team_line | cut -d"," -f2)" -F, '$4==current_team{print $1","$7}' $player_file \
			| sort -r -t ',' -n -k 2 | head -n 1 | awk -F, '{print $1, $2}'
		echo
	done
}

function print_modified_date {
	sed -e 1d $match_file | cut -d, -f1 | head -n 10 | sed \
  -e 's/\(Jan\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/01\/\2/g' \
  -e 's/\(Feb\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/02\/\2/g' \
  -e 's/\(Mar\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/03\/\2/g' \
  -e 's/\(Apr\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/04\/\2/g' \
  -e 's/\(May\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/05\/\2/g' \
  -e 's/\(Jun\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/06\/\2/g' \
  -e 's/\(Jul\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/07\/\2/g' \
  -e 's/\(Aug\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/08\/\2/g' \
  -e 's/\(Sep\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/09\/\2/g' \
  -e 's/\(Oct\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/10\/\2/g' \
  -e 's/\(Nov\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/11\/\2/g' \
  -e 's/\(Dec\) \([0-9]\{2\}\) \([0-9]\{4\}\) -/\3\/12\/\2/g'  
}

function print_teams {
	sed -e 1d $team_file | awk -F, '{print $1}'
}

function print_largest_difference {
	max=0
	IFS=$'\n'
	for match_line in $(sed -e 1d $match_file | awk -v team_name="$1" -F, '$3==team_name{print $5, $6}')
	do
		home_goal_count=$(echo $match_line | awk '{print $1}')
		away_goal_count=$(echo $match_line | awk '{print $2}')

		abs="$((home_goal_count - away_goal_count))"

		if [ $abs -gt $max ]; then
			max="$abs"
		fi
	done
	echo
	awk -v team_name="$1" -v max="$max" -F, '$3==team_name && (($5-$6)==max) {print $1; print $3" "$5" vs "$6" "$4"\n"}' $match_file
}

clear
echo
echo "************OSS1 - Project1************"
echo "*	StudentID : 12201729	*"
echo "*	Name : BeomJoon Park	*"
echo "******************************************"
echo

stop="N"
until [ "$stop" = "Y" ]
do
	echo "[MENU]"
	echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
	echo "2. Get the team data to enter a league position in teams.csv"
	echo "3. Get the Top-3 Attendance matches in mateches.csv"
	echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
	echo "5. Get the modified format of date_GMT in matches.csv"
	echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
	echo "7. Exit"
	read -p "Enter your CHOICE (1~7) : " choice

	case "$choice" in
	1)
		read -p "Do you want to get the Heung-Min Son's data? (y/n) : " choice
		if [ "$choice" = "y" ]; then
			print_player "Heung-Min Son"
		fi
		;;
	2)
		read -p "What do you want to get the team data of league_position[1~20] : " choice
		print_team $choice
		;;
	3)
		read -p "Do you want to know Top-3 attendance data? (y/n) : " choice
		if [ "$choice" = "y" ]; then
                        print_top3_attendance
                fi	
		;;
	4)
		read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " choice
		if [ "$choice" = "y" ]; then
                        print_top_scorer
                fi
		;;
	5)
		read -p "Do you want to modify the format of date? (y/n) : " choice
		if [ "$choice" = "y" ]; then
			print_modified_date
                fi
		;;
	6)
		PS3="Enter your team number : "
		IFS=$'\n'
		select team in $(print_teams)
		do
			print_largest_difference "$team"
			break
		done
		;;
	7)
		echo "Bye!"
		stop="Y"
		;;
	esac

	echo ""
done

