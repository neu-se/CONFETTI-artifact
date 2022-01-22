<?php
require("vendor/autoload.php");

$BASE_DIR = "/home/icse22ae/confetti-artifact";

// Use the us-east-2 region and latest version of each client.
$sharedConfig = [
        'profile' => 'default',
        'region' => 'us-east-2',
        'version' => 'latest'
];
// Create an SDK class used to share configuration across clients.
$sdk = new Aws\Sdk($sharedConfig);
// Use an Aws\Sdk class to create the S3Client object.
$s3Client = $sdk->createS3();

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

if($argc != 3){
	die('Usage: php runOneExperiment.php <evalScript> <experimentName>
	
	Where evalScript is one of: (benchmark)-(fuzzer), for valid combinations of:
		benchmark (ant, bcelgen, closure, maven, rhino), fuzzer (jqf,knarr-z3,knarr-z3-no-global-hint)

	experimentName is a string that you can choose, and will be included in the output file names.

');
}
$script = $argv[1];
$expName = $argv[2];

$logFile = "$BASE_DIR/results/$script/execution.log";
$quiet = getenv("CONFETTI_UNATTENDED");

if($quiet){
	print "Going into quiet mode. WARNING this will turn off your machine when done!\n";
	ob_start();
}
$resultsDir = "$BASE_DIR/results/$script";


$startTime = time();
print "------------------------------------------------------------------------\n";
print "confetti eval runner on: $script (".$argv[1]."), experiment run: $expName\n";
print "Start time: ".date("r")."\n";
print "------------------------------------------------------------------------\n";

if($quiet && !is_dir(getenv("HOME")."/.aws")){
	die("Quiet mode will not save results locally - it will push them to an S3 bucket, but you have not configured your aws credentials. Please configure the AWS credentials and place them in ~/.aws/config");
}
if(file_exists("$BASE_DIR/experiment-constraints")){
	execAndLog("Cleaning up old constraints" ,"rm -rf $BASE_DIR/experiment-constraints");
}

chdir("$BASE_DIR");
execAndLog("Confirming jqf-artifact revision", "git -C $BASE_DIR/ rev-parse HEAD");
execAndLog("Confirming jqf-confetti revision", "git -C $BASE_DIR/software/jqf/ rev-parse HEAD");
execAndLog("Confirming jqf-vanilla revision", "git -C $BASE_DIR/software/jqf-vanilla/ rev-parse HEAD");


$screenName = "exp-$expName-$startTime";
$extraArgs = "";
execAndLog("Running the experiment in screen", "$extraArgs screen -S '$screenName' -d -m bash -c \"$BASE_DIR/runExpInScreen.sh $script\"");
print "Waiting for screen to terminate\n";
$running = true;
while($running){
	sleep(30);
	$status = trim(exec("screen -list | grep $screenName"));
	$running = $status != "";
}

print "------------------------------------------------------------------------\n";
print "confetti eval runner $expName job done\n";
print "End time: ".date("r"). " (".(time()-$startTime)." seconds)\n";
print "------------------------------------------------------------------------\n";


if($quiet){
	execAndLog("Moving results to make tar easier...", "mv results/$script results/$expName");
    file_put_contents($logFile, ob_get_flush());
	$archiveName = "$expName.tgz";
	print "Uploading to S3: $logFile, $resultsDir\n";
	execAndLog("Creating result archive","tar czf $expName.tgz -C results/ $expName");
	//Save results
	try {
		$result = $s3Client->putObject([
		'Bucket' => 'knarr',
		'Key' => "batchRunner/$expName.tgz",
		'SourceFile' => "$expName.tgz"]);
	} catch (Exception $e) {
		echo "Caught exception: ", $e->getMessage(), "\n";
	}
	//Shutdown
	execAndLog("Shutting down","sudo shutdown -h now");
}

?>
