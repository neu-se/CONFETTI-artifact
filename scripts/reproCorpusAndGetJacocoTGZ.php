<?php
if(getenv("JQF_DIR") == null){
    die("Error: please run `source scripts/env.sh` before running this script");
}
    $configVanilla = "jqf";
    $configKnarr = "knarr-z3";
    $configKnarrNoGlobalHints = "knarr-z3-no-global-hint";
    $configClassic = "classicJQF";

    $benchmarks = [
        "ant" => ["class" => "ant.ProjectBuilderTest", "method" => "testWithGenerator",
            "coveragePackages" => ["org/apache/tools/ant/*"]],
        "bcelgen" => ["class" => "bcel.ParserTest", "method" => "testWithGenerator",
            "coveragePackages" => ["org/apache/bcel/*"]],
        "closure" => ["class" => "closure.CompilerTest", "method"=> "testWithGenerator",
            "coveragePackages" => ["com/google/javascript/jscomp/*"]],
        "maven" => ["class" => "maven.ModelReaderTest", "method" => "testWithGenerator",
            "coveragePackages" => ["org/apache/maven/model/*"]],
        "rhino" => ["class" => "rhino.CompilerTest", "method" => "testWithGenerator",
            "coveragePackages" => ["org/mozilla/javascript/*",
		"org/mozilla/classfile/*"
           ]] 
    ];

    function reproWithJacoco($jqfDir, $corpusDirs, $jacocoOut, $config, $extraENV=""){
        $jacocoIncludes = implode(":",$config['coveragePackages']);
        if(file_exists($jacocoOut)){
            unlink($jacocoOut);
        }
        $cmd = "$extraENV bash $jqfDir/scripts/repro_benchmark_with_jacoco.sh ".$config["class"]. " ". $config['method']. " ".$jacocoOut. " ". $jacocoIncludes . " " .$corpusDirs . " > /dev/null 2>&1";
		//echo "$cmd\n";
        `$cmd`;
    }
    function processJacocoResults($jqfDir, $jacocoExec, $htmlOutput, $config){
        if(file_exists($htmlOutput)){
            `rm -rf $htmlOutput`;
        }
        $includes = implode(":",$config['coveragePackages']);
        $includes = str_replace("*","", $includes);

        $cmd = "bash $jqfDir/scripts/get_coverage.sh $jacocoExec $includes $htmlOutput 2>&1";
		//echo "$cmd\n";
        $res = trim(shell_exec($cmd));
//        print "<$res>\n";
        $lines = explode("\n", $res);
        $cov = json_decode($lines[count($lines) - 1]);

//        print_r($cov);
        $covered = $cov->branchesCovered;
        $total = $cov->branchesTotal;
        return number_format($covered)."/".number_format($total). " (".round(100 * $covered/$total, 2)."%)\n";
    }
    function toCorpusPaths($dirs){
        $ret = "";
        foreach($dirs as $dir){
            $ret .= " ".$dir."/corpus";
        }
        return $ret;
    }
    function expandIfNeeded($tgzs, $to){
    	if(!file_exists($to))
		mkdir($to);
    	foreach($tgzs as $tgz){
		$name = basename($tgz,".tgz");
		if(!file_exists("$to/$name"))
			`tar xzf $tgz -C $to`;
	}
    }
    if($argc == 2){
        $resultDir = $argv[1];
    } else {
        $resultDir = getenv("FUZZ_OUTPUT");
    }
    $localDir = "/home/icse22ae/confetti-artifact/repro";
    $jqfDir = getenv("JQF_DIR");
    $jqfVanillaDir = getenv("JQF_VANILLA_DIR");
    if(!$resultDir || !file_exists($resultDir))
    	die("Could not find fuzz output directory. Did you source env.sh?");
    foreach($benchmarks as $bm => $config){
        print "=======$bm branch coverage=======\n";
	$jqfDirs = glob($resultDir."/*".$bm."-".$configVanilla."-*.tgz");
	$classicDirs = glob($resultDir."/*".$bm."-".$configClassic."-*.tgz");
	$noHintDirs = glob($resultDir."/*".$bm."-".$configKnarrNoGlobalHints."-*.tgz");
	$kd = glob($resultDir."/*".$bm."-".$configKnarr."-*.tgz");
	$knarrDirs = [];
	foreach($kd as $k => $d){
		if(!strstr($d,"no-global-hint")){
			$knarrDirs[]= $d;
		}
	}
	expandIfNeeded($jqfDirs, $localDir);
	// expandIfNeeded($classicDirs, $localDir);
	expandIfNeeded($knarrDirs, $localDir);
	expandIfNeeded($noHintDirs, $localDir);

        $jqfDirs = glob($localDir."/*".$bm."-".$configVanilla."-*", GLOB_ONLYDIR);
        $nJQF = count($jqfDirs);
        $jqfDirs = toCorpusPaths($jqfDirs);

	// $classicDirs = glob($localDir."/*".$bm."-".$configClassic."-*", GLOB_ONLYDIR);
    //     $nClassic = count($classicDirs);
    //     $classicDirs = toCorpusPaths($classicDirs);

        $kd = glob($localDir."/*".$bm."-".$configKnarr."-*", GLOB_ONLYDIR);
	$knarrDirs=[];
	foreach($kd as $k => $d){
		if(!strstr($d,"no-global-hint")){
			$knarrDirs[]= $d;
		}
	}

        $nKnarr = count($knarrDirs);
        $knarrDirs = toCorpusPaths($knarrDirs);

	$noHintDirs = glob($localDir."/*".$bm."-".$configKnarrNoGlobalHints."-*", GLOB_ONLYDIR);
        $nNoHint = count($noHintDirs);
        $noHintDirs = toCorpusPaths($noHintDirs);

        print "CONFETTI NoGlobalHints ($nNoHint runs): ";
        $jacocoExec = "$resultDir/$bm-$configKnarrNoGlobalHints.jacoco.exec";
        $htmlOutput = "$resultDir/$bm-$configKnarrNoGlobalHints.jacoco.out";
        reproWithJacoco($jqfDir, $noHintDirs, $jacocoExec, $config, "NO_GLOBAL_DICT=true");
        print "\t" . processJacocoResults($jqfDir, $jacocoExec, $htmlOutput, $config);

	// print "JQF-Classic ($nClassic runs): ";
    //     $jacocoExec = "$resultDir/$bm-$configClassic.jacoco.exec";
    //     $htmlOutput = "$resultDir/$bm-$configClassic.jacoco.out";
    //     reproWithJacoco($jqfVanillaDir, $classicDirs, $jacocoExec, $config);
        // print "\t" . processJacocoResults($jqfDir, $jacocoExec, $htmlOutput, $config);

        print "CONFETTI ($nKnarr runs): ";
        $jacocoExec = "$resultDir/$bm-$configKnarr.jacoco.exec";
        $htmlOutput = "$resultDir/$bm-$configKnarr.jacoco.out";
        reproWithJacoco($jqfDir, $knarrDirs, $jacocoExec, $config);
        print "\t" . processJacocoResults($jqfDir, $jacocoExec, $htmlOutput, $config);
	print "JQF ($nJQF runs): ";
        $jacocoExec = "$resultDir/$bm-$configVanilla.jacoco.exec";
        $htmlOutput = "$resultDir/$bm-$configVanilla.jacoco.out";
        reproWithJacoco($jqfVanillaDir, $jqfDirs, $jacocoExec, $config);
        print "\t" . processJacocoResults($jqfDir, $jacocoExec, $htmlOutput, $config);
	`rm -rf $localDir`;
    }
?>
