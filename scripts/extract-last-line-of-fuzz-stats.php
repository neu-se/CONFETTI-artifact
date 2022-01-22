<?php
    $configKnarr = "knarr-z3";
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
	$startTime = 0;
	$lastTime = 0;
	$timeCol = -1;
	$covCol = -1;
	$lastCov = 0;

    $resultDir = getenv("FUZZ_OUTPUT");
    if($resultDir == ""){
        die("Please be sure to source scripts/env.sh in this artifact before running this command\n");
    }
    // if(!file_exists($outputDir)){
		// mkdir($outputDir);
    // }
	$res = "bm,experiment,unix_time, cycles_done, cur_path, paths_total, pending_total, pending_favs, map_size, unique_crashes, unique_hangs, max_depth, execs_per_sec, total_inputs, mutated_bytes, valid_inputs, invalid_inputs, all_cov, z3, inputsSavedBy_StrHint, inputsCreatedBy_StrHint, inputsSavedBy_MultipleStrHint, inputsCreatedBy_MultipleStrHint, inputsSavedBy_CharHint, inputsCreatedBy_CharHint, inputsSavedBy_Z3, inputsCreatedBy_Z3, inputsSavedBy_Random, inputsCreatedBy_Random, inputsSavedWith_Hints, inputsSavedWith_Z3Origin, inputsSavedWithoutHintsOrZ3,countOfSavedInputsWithExtendedDictionaryHints,countOfCreatedInputsWithExtendedDictionaryHints,extendedDictionarySize\n";
    foreach($benchmarks as $bm => $config){
        $kd = glob($resultDir."/*".$bm."-".$configKnarr."-*.tgz");
		$knarrFiles = [];
		foreach($kd as $f)
			if(!strstr($f,"-no-global"))
				$knarrFiles[] = $f;
	
		foreach($knarrFiles as $f){
			$n = basename($f, ".tgz");
			$lastLine = trim(`tar -xOzf $f --no-anchored 'plot_data' | tail -n 1`);
			$res .= "$bm,$n,$lastLine\n";
		}
    }
    if(!is_dir("/home/icse22ae/confetti-artifact/generated")){
        mkdir("/home/icse22ae/confetti-artifact/generated");
    }
	file_put_contents("/home/icse22ae/confetti-artifact/generated/fuzz_stats.csv",$res);
?>
