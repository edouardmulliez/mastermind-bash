#!/bin/bash

# Mastermind game

select_random_char(){
    # Echo 1 character from string S, chosen randomly.
    local S=$1
    local N=$(( 1 + $RANDOM % ${#S} ))
    echo $S | head -c $N | tail -c 1
}

generate_random_code(){
    # Generate a random code composed of 5 distinct capital letters among ABCDEFGH.
    local REMAINING_LETTERS='ABCDEFGH'
    local CHOSEN_LETTER
    local CODE=

    for i in {1..5}
    do
        CHOSEN_LETTER=$( select_random_char $REMAINING_LETTERS )
        REMAINING_LETTERS=$( echo $REMAINING_LETTERS | tr -d $CHOSEN_LETTER )
        CODE+="$CHOSEN_LETTER"
    done

    echo $CODE
}

is_valid(){
    # Check if string S is a valid code proposition: 5 capital letters among letters 'ABCDEFGH'
    local S
    local LENGTH
    S=$1
    LENGTH=5

    if [ ! ${#S} = $LENGTH ]; then
        echo "Invalid proposition: code should be of length $LENGTH"
        exit 1
    fi
    if [[ ! $S =~ ^[A-H]{5}$ ]]; then
        echo "Invalid proposition: code should be composed of 5 capital letters among 'ABCDEFGH'."
        exit 1
    fi
    echo "Valid proposition."
    exit 0
}

get_exact_match(){
    # Get count of characters at same position in S1 and S2
    local S1=$1
    local S2=$2
    local COUNT=0

    for i in {1..5}
    do  
        C_S1=$( echo $S1 | head -c $i | tail -c 1 )
        C_S2=$( echo $S2 | head -c $i | tail -c 1 )
        if [ $C_S1 = $C_S2 ]; then
            (( COUNT++ ))
        fi
    done

    echo $COUNT
}

get_approx_match(){
    # Get count of characters in S2 that are also in S1 but at a different position
    local S1=$1
    local S2=$2
    local COUNT=0
    local C_S1
    local C_S2
    
    for i in {1..5}
    do
        C_S1=$( echo $S1 | head -c $i | tail -c 1 )
        C_S2=$( echo $S2 | head -c $i | tail -c 1 )

        if [ ! $C_S1 = $C_S2 ] && [[ $S1 = *"$C_S2"* ]] ; then
            (( COUNT++ ))
        fi
    done
    echo $COUNT
}

repeat_string(){
    # Repeat string S, N times.
    local S=$1
    local N=$2

    if [ $N -gt 0 ]; then
        yes $S | head -n $N | tr -d '\n'
    fi
}

display_help(){
    echo ""
    echo "================= HELP ==================="
    echo ""
    echo "You will have N attempts to guess the code. The code is constituted of 5 distinct capital letters among 'ABCDEFGH'."
    echo "For each attempt, you have to propose a code of 5 (distinct or not) letters (in ABCDEFGH)."
    echo "Then, you will see how many characters of your proposition were:"
    echo "    - in the code and well positioned (B)"
    echo "    - or in the code and misplaced (W)"
    echo "For example, if the code is 'ADHGE' and you propose 'EAEGG' then the answer will be:"
    echo "    EEEGG ==> BWW__"
    echo 'Explanation: The letter G is well positioned (B), the letters A and E are not well positioned (WW).'
    echo ""
    echo "==========================================="
    echo ""
}

display_success(){
    echo ""
    echo "==========================================="
    echo ""
    echo "Congratulations, you guessed the correct code !!!"
    echo ""
    echo "==========================================="
    echo ""
}

display_defeat(){
    local CODE=$1
    echo ""
    echo "==========================================="
    echo ""
    echo "You didn't find the correct code in $MAX_TRY_NB attempts."
    echo "The correct code was $CODE"
    echo "Try again!"
    echo ""
    echo "==========================================="
    echo ""
}

display_welcome(){
    echo ""
    echo "==============================="
    echo ""
    echo "Welcome to the MASTERMIND Game!"
    echo ""
}


play_game(){
    
    local CODE=$( generate_random_code )
    local CODE_FOUND=0
    local TRY_NB=1
    local REMAINING_NB
    local ANS
    local BLACK_NB
    local WHITE_NB
    local OTHER_NB

    while [ $CODE_FOUND = 0 ] && [ $TRY_NB -le $MAX_TRY_NB ]
    do
        REMAINING_NB=$(( MAX_TRY_NB - TRY_NB + 1 ))
        read -p "You have $REMAINING_NB attempts left. Propose a code: " TRY
        # Check if TRY is a valid proposition
        ERR_MESSAGE=$( is_valid $TRY )
        if [ ! $? == 0 ]; then
            echo $ERR_MESSAGE
            continue
        fi

        BLACK_NB=$( get_exact_match $TRY $CODE )
        WHITE_NB=$( get_approx_match $TRY $CODE )
        OTHER_NB=$(( 5 - BLACK_NB - WHITE_NB))

        # Print string indicating correct characters and positions
        ANS=$( repeat_string B $BLACK_NB )
        ANS+=$( repeat_string W $WHITE_NB )
        ANS+=$( repeat_string _ $OTHER_NB )
        echo "        $TRY ==> $ANS"

        if [ $BLACK_NB == 5 ]; then
            display_success
            CODE_FOUND=1
        fi

        (( TRY_NB++ ))

        if [ $CODE_FOUND == 0 ] && [ $TRY_NB -gt $MAX_TRY_NB ]; then
            display_defeat $CODE
        fi

    done
}


## MENU

###### Game parameters ##########

MAX_TRY_NB=12

#################################


display_welcome
display_help

PS3='Please enter the number corresponding to your choice: '
options=("Start a new game" "Display help" "Quit")

while true
do
    select opt in "${options[@]}"
    do
        case $opt in
            'Start a new game')
                play_game
                break
                ;;
            'Display help')
                display_help
                break
                ;;
            'Quit')
                exit 0
                ;;
            *) echo 'Invalid option. Please type a number between 1 and 3.';;
        esac
    done
done






