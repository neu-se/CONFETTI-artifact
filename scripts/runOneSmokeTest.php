<?php

$BASE_DIR = "/home/icse22ae/confetti-artifact";

function execAndLog($note,$cmd){
    print "------------------------------------------------------------------------\n";
    print "$note\n";
    print "------------------------------------------------------------------------\n";

    print "Running: $cmd\n";
    $err = 0;
    $time = time();
    passthru($cmd." 2>&1",$err);
    $duration = time()- $time;
    print "Return code: $err. Duration: $duration seconds \n";
    return $err;
}

if($argc != 2){
	die('Usage: php runOneSmokeTest.php <evalScript> 
	
	Where evalScript is one of: (benchmark)-(fuzzer), for valid combinations of:
		benchmark (ant, bcelgen, closure, maven, rhino), fuzzer (jqf,knarr-z3,knarr-z3-no-global-hint)
');
}
$script = $argv[1];
$expName = "$script-1";

$resultsDir = "$BASE_DIR/results/$script";


$startTime = time();
print "------------------------------------------------------------------------\n";
print "confetti eval runner on: $script\n";
print "Start time: ".date("r")."\n";
print "------------------------------------------------------------------------\n";

if(file_exists("$BASE_DIR/experiment-constraints")){
	execAndLog("Cleaning up old constraints" ,"rm -rf $BASE_DIR/experiment-constraints");
}

chdir("$BASE_DIR");
execAndLog("Confirming jqf-artifact revision", "git -C $BASE_DIR/ rev-parse HEAD");
execAndLog("Confirming jqf-confetti revision", "git -C $BASE_DIR/software/jqf/ rev-parse HEAD");
execAndLog("Confirming jqf-vanilla revision", "git -C $BASE_DIR/software/jqf-vanilla/ rev-parse HEAD");


$screenName = "exp-$expName-$startTime";
execAndLog("Running the experiment in screen. If you want to 
snoop on the run, in another shell run `screen -r $screenName` (do not terminate it though!)",
	"screen -S '$screenName' -d -m bash -c \"$BASE_DIR/experiments/$script/run.sh\"");
print "Waiting for screen to terminate\n";
$running = true;
while($running){
	sleep(30);
	$status = trim(exec("screen -list | grep $screenName"));
	$running = $status != "";
}

execAndLog("Moving results to follow same format as full experimental runs...", "mv results/$script results/$expName");
$archiveName = "$expName.tgz";
execAndLog("Creating result archive","tar czf local_eval_output/$expName.tgz -C results/ $expName");
execAndLog("Removing the files that are now archived", "rm -rf results/*");

print "------------------------------------------------------------------------\n";
print "confetti eval runner $expName job done\n";
print "End time: ".date("r"). " (".(time()-$startTime)." seconds)\n";
print "------------------------------------------------------------------------\n";

?>
