<?php
    $configVanilla = "jqf";
    $configKnarr = "knarr-z3";
    $benchmarks = [
        "ant" => ["class" => "ant.ProjectBuilderTest", "method" => "testWithGenerator",
            "coveragePackages" => ["org/apache/tools/ant/*"]],
        "bcelgen" => ["class" => "bcel.ParserTest", "method" => "testWithGenerator",
            "coveragePackages" => ["org/apache/bcel/verifier/*"]],
        "closure" => ["class" => "closure.CompilerTest", "method"=> "testWithGenerator",
            "coveragePackages" => ["com/google/javascript/jscomp/*"]],
        "maven" => ["class" => "maven.ModelReaderTest", "method" => "testWithGenerator",
            "coveragePackages" => ["org/apache/maven/model/*"]],
        "rhino" => ["class" => "rhino.CompilerTest", "method" => "testWithGenerator",
            "coveragePackages" => ["org/mozilla/javascript/optimizer/*",
            "org/mozilla/javascript/CodeGenerator*"]]
    ];

    $resultDir = getenv("FUZZ_OUTPUT");
    $jqfDir = getenv("JQF_DIR");
    $jqfVanillaDir = getenv("JQF_VANILLA_DIR");
    // $cmds = "";
    foreach($benchmarks as $bm => $config){
        //print "=======$bm=======\n";
        $knarrDirs = glob($resultDir."/*".$bm."-".$configKnarr."-*.tgz");
        foreach($knarrDirs as $experiment){
			if(strstr($experiment,"-no-global"))
				continue;
            $exp = basename($experiment);
            $thisExp = [];
            $batches = [];
			$outputFile = $experiment.".forensics-1k.csv";
			$cmd = "EXP_NAME=$exp APP_NAME=$bm TRIALS=1000 bash /home/icse22ae/confetti-artifact/scripts/evaluate_extended_dict_wrapper.sh ".$config["class"]. " ". $config['method']. " " .$outputFile." $experiment \n";
            echo $cmd;
            echo `$cmd`;

        }
    }
	print $cmds;
?>
