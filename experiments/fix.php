<?php
foreach(glob("*-confetti*") as $confettiDir ){
    `sed -i 's/-confetti/-knarr-z3/' $confettiDir/run.sh`;
    $newDir = str_replace("-confetti","-knarr-z3", $confettiDir);
    `mv $confettiDir $newDir`;
}
?>