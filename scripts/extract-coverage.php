<?php
if($argc != 3)
	die("Usage: php extract-coverage.php primaryDataInputDir intermediateDataOutputDir");

$inputDir = $argv[1];
$outputDir = $argv[2];
    $configVanilla = "jqf";
    $configKnarr = "knarr-z3";
    $configKnarrNoDict = "knarr-z3-no-global-hint";
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
            "coveragePackages" => ["org/mozilla/javascript/optimizer/*",
            "org/mozilla/javascript/CodeGenerator*"]]
    ];
    function expandIfNeeded($tgzs, $to){
        if(!file_exists($to))
                mkdir($to);
        foreach($tgzs as $tgz){
                $name = basename($tgz,".tgz");
                if(!file_exists("$to/$name/plot_data"))
                        `tar xzf $tgz -C $to $name/plot_data`;
        }
    }
    function createTruncatedFile($from,$to){
    	print "$from,$to\n";
	$in = fopen($from,"r");
	$out = fopen($to,"w");
	if(!$in || !$out){
		print("Unable to open one of the files $from, $to");
		if($out)
			fclose($out);
		if($in)
			fclose($in);
		return;
	}
	$startTime = 0;
	$lastTime = 0;
	$timeCol = -1;
	$covCol = -1;
	$lastCov = 0;
	fwrite($out,"time,cov\n");
	while(($line = fgetcsv($in, 1000,",")) !== FALSE){
		if($timeCol == -1){
			$cols = $line;
			foreach($cols as $i => $col){
				if(trim($col) == "# unix_time"){
					$timeCol = $i;
				}
				else if(trim($col) == "all_cov"){
					$covCol = $i;
				}
			}
			continue;
		}
		$time = trim($line[$timeCol]);
		$cov = trim($line[$covCol]);
		if($startTime == 0){
			$startTime = $time;
		}
		$time = round(($time-$startTime)/60);
		if($time == $lastTime){
			if($cov > $lastCov)
				$lastCov = $cov;
			continue;
		}
		while($lastTime < $time - 1){
			fwrite($out,"$lastTime,$lastCov\n");
			$lastTime++;
		}
		fwrite($out,"$lastTime,$lastCov\n");
		$lastTime = $time;

	}
	fwrite($out,"$lastTime,$lastCov\n");
	fclose($out);
	fclose($in);

    }

	$root = getenv("ROOT");
    $resultDir = $inputDir;
    $localDir = "$root/coverage-tmp";
    if(!file_exists($outputDir)){
	mkdir($outputDir);
    }
    $jqfDir = getenv("JQF_DIR");
    $jqfVanillaDir = getenv("JQF_VANILLA_DIR");
    foreach($benchmarks as $bm => $config){
        $jqfDirs = glob($resultDir."/*".$bm."-".$configVanilla."-*.tgz");
        $knarrDirs = glob($resultDir."/*".$bm."-".$configKnarr."-*.tgz");
	$knarrNoDictDirs = glob($resultDir."/*".$bm."-".$configKnarrNoDict."-*.tgz");
        expandIfNeeded($jqfDirs, $localDir);
        expandIfNeeded($knarrDirs, $localDir);
	expandIfNeeded($knarrNoDictDirs, $localDir);
	foreach($jqfDirs as $f){
		if(strstr($f,"jacoco.out")) continue;
		$n = basename($f, ".tgz");
		createTruncatedFile($localDir."/".$n."/plot_data",$outputDir."/".$n."-coverage.csv");
	}
	foreach($knarrDirs as $f){
		if(strstr($f,"jacoco.out")) continue;
		$n = basename($f, ".tgz");
		createTruncatedFile($localDir."/".$n."/plot_data",$outputDir."/".$n."-coverage.csv");
	}
	foreach($knarrNoDictDirs as $f){
		if(strstr($f,"jacoco.out")) continue;
		$n = basename($f, ".tgz");
		createTruncatedFile($localDir."/".$n."/plot_data",$outputDir."/".$n."-coverage.csv");
	}

	`rm -rf $localDir`;
    }
?>
