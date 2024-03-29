#!/bin/bash -i
# shellcheck disable=SC2317

# Check prereqs
command -v awk > /dev/null 2>&1 || { echo "awk is missing"; exit 1; }
command -v docker > /dev/null 2>&1 || { echo "docker is missing"; exit 1; }
command -v md5sum > /dev/null 2>&1 || { echo "md5sum is missing"; exit 1; }
command -v sleep > /dev/null 2>&1 || { echo "sleep is missing"; exit 1; }
command -v tmux > /dev/null 2>&1 || { echo "tmux is missing"; exit 1; }

if [ -z "$1" ]; then
    docker_image="lacledeslan/gamesvr-ut2004-freeplay";
else
    docker_image=$1;
fi

#####################################################################################################
### CONFIG VARS #####################################################################################
declare LLTEST_CMD="docker run --rm $docker_image /app/System/ucc-bin server DM-Gael?game=XGame.xDeathMatch -nohomedir -lanplay";
declare LLTEST_NAME && LLTEST_NAME="gamesvr-ut2004-freeplay-$(date '+%H%M%S')";
#####################################################################################################
#####################################################################################################

# Runtime vars
declare LLCOUNTER=0;
declare LLBOOT_ERRORS="";
declare LLTEST_HASFAILURES=false;
declare LLTEST_LOGFILE="$LLTEST_NAME"".log";
declare LLTEST_RESULTSFILE="$LLTEST_NAME"".results.log";

# Server log file should contain $1 because $2
function should_have() {
    if ! grep -i -q "$1" "$LLTEST_LOGFILE"; then
        echo $"[FAIL] - '$2'" >> "$LLTEST_RESULTSFILE";
        LLTEST_HASFAILURES=true;
    else
        echo $"[PASS] - '$2'" >> "$LLTEST_RESULTSFILE";
    fi;
}

# Server log file should NOT contain $1 because $2
function should_lack() {
    if grep -i -q "$1" "$LLTEST_LOGFILE"; then
        echo $"[FAIL] - '$2'" >> "$LLTEST_RESULTSFILE";
        LLTEST_HASFAILURES=true;
    else
        echo $"[PASS] - '$2'" >> "$LLTEST_RESULTSFILE";
    fi;
}

# Command $1 should make server return $2
function should_echo() {
    if ! tmux has-session -t "$LLTEST_NAME" 2>/dev/null;
    then
        LLCOUNTER=0;
        LLTMP=$(md5sum "$LLTEST_LOGFILE");
        tmux send -t "$LLTEST_NAME" C-z "$1" Enter;

        while true; do
            sleep 0.5;

            if  (( "$LLCOUNTER" > 30)); then
                echo $"[FAIL] - Command '$!' TIMED OUT";
                LLTEST_HASFAILURES=true;
                break;
            fi;

            if [[ $(md5sum "$LLTEST_LOGFILE") != "$LLTMP" ]]; then
                should_have "$2" "'$1' should result in '$2' (loop iterations: $LLCOUNTER)";
                break;
            fi;

            (( LLCOUNTER++ ));
        done;
    else
        echo $"[ERROR]- Could not run command '$1'; tmux session not found" >> "$LLTEST_RESULTSFILE";
        LLTEST_HASFAILURES=true;
    fi;
}

function print_log() {
    if [ ! -s "$LLTEST_LOGFILE" ]; then
        echo $'\nOUTPUT LOG IS EMPTY!\n';
        exit 1;
    else
        echo $'\n[LOGFILE OUTPUT]';
        awk '{print "»»  " $0}' "$LLTEST_LOGFILE";
    fi;
}

# Prep log file
: > "$LLTEST_LOGFILE"
if [ ! -f "$LLTEST_LOGFILE" ]; then
    echo 'Failed to create logfile: '"$LLTEST_LOGFILE"'. Verify file system permissions.';
    exit 2;
fi;

# Prep results file
: > "$LLTEST_RESULTSFILE"
if [ ! -f "$LLTEST_RESULTSFILE" ]; then
    echo 'Failed to create logfile: '"$LLTEST_RESULTSFILE"'. Verify file system permissions.';
    exit 2;
fi;

echo $'\n\nRUNNING TEST: '"$LLTEST_NAME";
echo $'Command: '"$LLTEST_CMD";
echo "Running under $(id)"$'\n';

# Execute test command in tmux session
tmux new -d -s "$LLTEST_NAME" "sleep 0.5; $LLTEST_CMD";
sleep 0.3;
tmux pipe-pane -t "$LLTEST_NAME" -o "cat > $LLTEST_LOGFILE";

while true; do
    if ! tmux has-session -t "$LLTEST_NAME" 2>/dev/null;
    then
        echo $'terminated.\n';
        LLBOOT_ERRORS="Test process self-terminated";
        break;
    fi;

    if  (( "$LLCOUNTER" >= 19 )); then
        if [ -s "$LLTEST_LOGFILE" ] && ((( $(date +%s) - $(stat -L --format %Y "$LLTEST_LOGFILE") ) > 10 )); then
            echo $'succeeded.\n';
            break;
        fi;

        if (( "$LLCOUNTER" > 120 )); then
            echo $'timed out.\n';
            LLBOOT_ERRORS="Test timed out";
            break;
        fi;
    fi;

    if (( LLCOUNTER % 5 == 0 )); then
        echo -n "$LLCOUNTER...";
    fi;

    (( LLCOUNTER++ ));
    sleep 1;
done;

if [ ! -s "$LLTEST_LOGFILE" ]; then
    echo $'\nOUTPUT LOG IS EMPTY!\n';
    exit 1;
fi;

if [ -n "${LLBOOT_ERRORS// }" ]; then
    echo "Boot error: $LLBOOT_ERRORS";
    print_log;
    exit 1;
fi;

#####################################################################################################
### TESTS ###########################################################################################
should_have 'Executing Class Engine.ServerCommandlet' 'Server started';
should_have "Game class is 'xDeathMatch'" 'Server loaded deathmatch';
should_have 'Bringing Level DM-Gael.myLevel up for play' 'Server should load level DM-Gael';
should_have 'GameInfo::InitGame' 'Server should initialize game';
should_lack 'Resolving master0.gamespy.com...' 'server is not attempting to send stats to gamespy'
should_lack 'Resolving ut2004master1.epicgames.com...' 'server is not attempting to connect to epic list server';
#####################################################################################################
#####################################################################################################

if ! tmux has-session -t "$LLTEST_NAME" 2>/dev/null;
then
    tmux kill-session -t "$LLTEST_NAME";
fi;

print_log;

echo $'\n[TEST RESULTS]\n';
cat "$LLTEST_RESULTSFILE";

echo $'\n[OUTCOME]\n';
if [ $LLTEST_HASFAILURES = true ]; then
    echo $'Checks have failures!\n\n';
    exit 1;
fi;

echo $'All checks passed!\n\n';
exit 0;
