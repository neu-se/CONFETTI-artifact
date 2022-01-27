# Artifact for CONFETTI: CONcolic Fuzzer Employing Taint Tracking Information
Fuzz testing (fuzzing) allows developers to detect bugs and vulnerabilities in code by automatically generating defect-revealing inputs. Most fuzzers operate by generating inputs for applications and mutating the bytes of those inputs, guiding the fuzzing process with branch coverage feedback via instrumentation.
Whitebox guidance (e.g., taint tracking or concolic execution) is sometimes integrated with coverage-guided fuzzing to help  cover tricky-to-reach branches that are guarded by complex conditions (so-called "magic values"). This integration typically takes the form of a targeted input mutation, for example placing particular byte values at a specific offset of some input in order to cover a branch. However, these dynamic analysis techniques are not perfect in practice, which can result in the loss of important relationships between input bytes and branch predicates, thus reducing the effective power of the technique.

CONFETTI introduces a new, surprisingly simple, but effective technique, *global hinting*, which allows the fuzzer to insert these interesting bytes not only at a targeted position, but in any position of any input. We implemented this idea in Java, creating CONFETTI, which uses both targeted and global hints for fuzzing. In an empirical comparison with two baseline approaches, a state-of-the-art greybox Java fuzzer and a version of CONFETTI without global hinting, we found that CONFETTI covers more branches and finds 15 previously unreported bugs, including 9 that neither baseline could find.

CONFETTI is a research prototype, but nonetheless, we have had success applying it to fuzz the open-source projects Apache Ant, BCEL and Maven, Google's  Closure Compiler, and Mozilla's Rhino engine.

## About this artifact
We provide an artifact of our development and evaluation of CONFETTI that contains all of our code, scripts, dependencies and results in a Virtual Machine image, which we believe will provide a stable reference to allow others to be sure that they can make use of our tool and results in the future. However, we recognize that there is a significant tension between an artifact that is "resuable" and one which is stable. In the context of the rapidly-evolving field of fuzzers, "reusable" is likely best signified by a repository and set of continuous integration workflows that allow other researchers to fork our repository, develop new functionality, and automatically conduct an evaluation. For example, we found this artifact particularly useful when we used it in preparation of a [pull-request that we provided](https://github.com/rohanpadhye/JQF/pull/171) to the upstream maintainers of the baseline fuzzer that we compared to, JQF.

A continuous integration artifact likely has an enormous number of external dependencies that are not possible to capture - such as the provisioning and configuration of the CI server itself. We make our "live" continuous integration artifact available [on GitHub](https://github.com/neu-se/CONFETTI), and have permanently archived our CI workflow and its components [on FigShare](https://doi.org/10.6084/m9.figshare.16563776). This virtual machine image is less likely to be useful than our CI workflow for reusing CONFETTI, but will be resilient to bitrot, since it is fully self-contained

Reviewers of this artifact should:
* Have VirtualBox or VMWare available to run our VM. It requires 4 CPU cores, 32GB RAM, and the disk image is approximately 20 GB.
* We recommend using VirtualBox over VMWare. We used the base VM image distributed by the artifact evaluation chairs, which we found could be fickle with VMWare, although we were ultimately able to make it work with both. 
* In either solution, reviewers need to create a new VM (Linux 64bit) as specified above with 32GB RAM and 4 CPUs, and attach the provided VMDK as the first storage device (e.g. SATA port 0 on VirtualBox)

Ideally, reviewers might also consider checking to see whether they can build and run CONFETTI directly on their local machines and run a short (3-5 minute) fuzzing campaign, to validate that this simpler development model is also possible. The requirements for running CONFETTI directly on a machine are:
* Mac OS X or Linux (we have tested extensively with Ubuntu, other versions are sure to work, but may require manually installing the correct [release of z3 version 4.6 for the OS](https://github.com/Z3Prover/z3))
* Have Java 8 installed, with the `JAVA_HOME` environmental variable configured to point to that Java 8 JDK
* Have Maven 3.x installed
* Have at least 16GB RAM


### Updating this artifact
This document is in a snapshot of a living artifact.

You are most likely either reading this document in our GitHub repo, [neu-se/confetti-artifact](https://github.com/neu-se/confetti-artifact),  but this document and entire repository also exist within a Virtual Machine that is packed with all of the software and dependencies that we used to perform our evaluation, along with copies of all of the primary data that we collected and the intermediate data that we processed.

If you are ambitious, you are reading document in a VM that contains a clone of a [github](https://github.com/neu-se/confetti-artifact), and are ready to poke around in it.
If you need to update this VM, you can simply run `git pull` in this directory.
When we make a new release of the artifact, we publish a new VM to [FigShare](https://doi.org/10.6084/m9.figshare.16563776), ensuring that this entire process remains reproducible without any external dependencies.

### A suggested path to evaluate this artifact
Our experimental results require an enormous quantity of computational resources to generate: there are 20 trials each of three fuzzers on 5 target applications, where each trial takes 24 hours. We do not expect reviewers to repeat this entire evalution. 

For each of the tables and figures that appear in the paper, there are generally 2-3 scripts that get run:
1. A perhaps very-long running (24 hour+) script that collects some primary data
2. A perhaps shorter, but still longer running (10 minutes - 2 hours) script that processes the primary data into an intermediate representation
3. A very fast running script that proceses the intermediate data into the final results that appear in the paper

A downside to having multiple scripts is that there is no single script for you to run to re-do the entire experiment. However, given the CPU time needed for gathering primary data, we think that the extra steps are well-worth the benefits for ease of use, debugging, and extension. We provide instructions to allow reviewers to process the same primary data that we used for our ICSE 22 paper (24 hours, 5 target apps, three fuzzers, 20 trials) through our data pipeline in order to confirm that the tables and graphs in the paper can be reproduced from this data. We also provide instructions to allow reviewers to conduct a much shorter evaluation (10 minutes, 5 target apps, three fuzzers, 1 trial), and then to process all of that data through the same scripts to generate tables and graphs.

We would suggest the following path through this artifact to evalaute it:
1. Follow the steps under [Producing the tables and graphs from the results](#producing-the-tables-and-graphs-from-the-results). In each subsection look for this "pre-bake" icon 🎂, which will draw your attention to where to start to generate the tables and graphs using our previously-copmuted intermediate results. This should allow you to traverse this entire document without needing to wait for any long running computation. You can validate that the results match (or nearly match; some parts remain non-deterministic due to timing, and expected deviations are noted where applicable). For convenience, the pre-bake results are all included in our artifact VM *and* available directly on FigShare.
2. Run a fuzzing campaign, starting from [Running a fuzzing campaign in the artifact](#running-a-fuzzing-campaign-in-the-artifact). The shortest campaign that will generate sufficient data to be used by the rest of the data procesing pipeline will run all 3 fuzzers on all 5 benchmarks for 10 minutes each, with no repeated trials. This should take a bit under 3 hours to run. Our instructions show how to run the exact configuration that we performed in the paper and included the pre-bake 🎂 results for (24 hours x 20 trials x 3 fuzzers x 5 benchmarks), but look for the 🕒 *three oclock symbol* 🕒, which will draw your attention to specific instructions for running a shorter experiment.
3. Browse our "live" development artifact: a [Continuous Integration workflow](#continous-integration-artifact) that uses our institution's HPC resources to execute short (10 minutes x 5 trials x 5 benchmarks) evalautions on each revision of our repository, and optionally full-scale (24 hour x 20 trials x 5 benchmarks) fuzzing campaigns. We would be happy to trigger this GitHub Action to run on our CI workers if you submit a pull request. 

## The "traditional" artifact (VM)
In our [ICSE 2022 paper](https://jonbell.net/publications/CONFETTI), we evaluated JQF-Zest, CONFETTI, and a variant of CONFETTI with global hints disabled.
This section describes how to reproduce those experiments, and includes pointers to the logs and results produced from our evaluation.
Note that we imagine that for future development, it will be far easier to use the Continuous Integration process described in the prior section to conduct performance evaluations.
However, we did not implement that process until *after* submitting the ICSE 2022 paper, and hence, with the goal of reproducibility, describe the exact steps to reproduce those results.
We executed the evaluation reported in the paper on Amazon's EC2 service, using `r5.xlarge` instances, each with 32GB of RAM and 4 CPUs.
We executed our experiments in parallel by launching one VM for each run (e.g. 20 trials x 3 fuzzers x 5 benchmarks = 300 VMs for 24 hours), where each VM had the same configuration as this artifact VM.
We then collected the results from each of those VMs; all of these results are included inside of this artifact and are also directly available for download on our [FigShare artifact](https://doi.org/10.6084/m9.figshare.16563776).

We provide an Ubuntu 20 VM that contains the exact same versions of all packages that we used in our paper evaluation.
The username and password to login to this VM are both `icse22ae`, and it has an SSH server running on port 22.

We provide a brief overview of the software contained in the artifact to help future researchers who may want to modify CONFETTI or any of its key dependencies. We expect that this use-case (modifying the code, recompiling, and running it) will be best supported by our Continuous Integration artifact described above, but the VM provides the most resilience to bitrot, as it includes all external dependencies and can be executed without being connected to the internet.

The artifact VM contains a suitable JVM, OpenJDK 1.8.0_312, installed to `/usr/lib/jvm/java-8-openjdk-amd64/`. The CONFETTI artifact is located in `/home/icse22ae/confetti-artifact`, and contains compiled versions of all dependencies. The artifact directory contains scripts to run the evaluation, and we include the source code of all of CONFETTI's key components, which can be modified and built without connecting to the internet to fetch any additional dependencies. These projects can be re-built by running the `scripts/build-all.sh` or `scripts/build/[project].sh` script.

The key software artifacts are located in the `software` directory of the artifact:
* `jqf`: CONFETTI (named `jqf` for historical purposes), specifically [neu-se/confetti](https://github.com/neu-se/confetti)@[icse-22-evaluation](https://github.com/neu-se/CONFETTI/releases/tag/icse-22-evaluation) - The revision of CONFETTI that we evaluated
* `jqf-vanilla`: The baseline version of JQF we compared to, specifically [neu-se/jqf-non-colliding-coverage](https://github.com/neu-se/jqf-non-colliding-coverage)@[jqf-1.1-with-non-colliding-coverage](https://github.com/neu-se/jqf-non-colliding-coverage/tree/jqf-1.1-with-non-colliding-coverage). See discussion of patches we wrote for JQF below.
* `knarr`: [gmu-swe/knarr](https://github.com/gmu-swe/knarr)@[icse-22-confetti-evaluation](https://github.com/gmu-swe/knarr/tree/icse-22-confetti-evaluation) - The constraint tracking runtime used by CONFETTI
* `green`: [gmu-swe/green-solver](https://github.com/gmu-swe/green-solver)
* `jacoco-fix-exception-after-branch`: [neu-se/jacoco](https://github.com/neu-se/jacoco/)@[fix-exception-after-branch](https://github.com/neu-se/jacoco/tree/fix-exception-after-branch) - Patched version of JaCoCo that we used to collect coverage. We found that JaCoCo wouldn't record a branch edge as covered if it was covered, and then immediately after an exception was thrown. This complicated debugging and analysis of the JaCoCo HTML output reports; this branch has that bug fixed, and it is this version of JaCoCo that is included in the artifact, and in the `software/jqf/jacoco-jars` directory.
* `software/z3`: Binaries from [Z3Prover/z3](https://github.com/Z3Prover/z3), release version [4.6.0](https://github.com/Z3Prover/z3/releases/tag/z3-4.6.0), of the `x64-ubuntu-16.04` flavor. This is the version of Z3 that we used in our evaluation.

Other software installed in the VM to support running the experiment scripts are:
* SSH server: we find it easiest to run VSCode outside of the VM, and use the "connect to remote" feature to connect your local VSCode instance to the artifact
* R: Plots and tables are generated using R. Installed packages include `readr, tidyr, plyr, ggplot2, xtable, viridis, fs, forcats`
* PHP: Some of our experiment scripts are written in PHP. We promise to stop using PHP for scripting after this project :)

**All commands below should be executed in the `confetti-artifact` directory in the artifact**

### Running a fuzzing campaign in the artifact
To run a fuzzing campaign in the artifact, use the script `scripts/runExpInScreen.sh`, which takes a single parameter: the experiment to run. This script will run the specified experiment with a timeout of 24 hours, if you would like it to terminate sooner, you can end it by typing control-C.

The experiment name is the combination of the target application to fuzz with the fuzzer to evalaute. The list of target application names is  (`ant`, `bcelgen`, `closure`, `maven`, `rhino`). The list of fuzzers to evaluate are `knarr-z3`, `knarr-z3-no-global-hint`, and `jqf`. Within this artifact, `knarr-z3` stands in for the name `CONFETTI`, and `knarr-z3-no-global-hint` stands in for `CONFETTI-NoGlobalHint` (it is perhaps not unusual for names of papers to be decided at the last minute prior to paper submission, and we include here the artifact of scripts we used to prepare the results in the paper, before that final name change). 

We have also included a script, `scripts/runOneExperiment.php`, that we used to automate running a fuzzing experiment in a "headless" mode, where the experiment runs for 24 hours, then copies the results to an Amazon S3 bucket, and then shuts down the VM. This is the exact script that we used to run our experiment on EC2. There is additional configuration necessary to provision an S3 bucket for use with the script; if a reviewer is familiar with S3 already then the configuration should be fairly self explanatory, but providing detailed instructions to provision a large-scale experiment is a non-goal for this artifact.

🎂 *Pre-bake available* 🎂 The results presented in our paper are the result of running each of these experiments 20 times for 24 hour each. We include the raw results produced by running our `scripts/runOneExperiment.php` script in the directory `icse_22_fuzz_output`.  You can also download these results direclty from our [FigShare artifact](https://doi.org/10.6084/m9.figshare.16563776), they are included int he archive `fuzz_output.tgz`. In these result files, note that the name "Knarr-z3" is used in place of "CONFETTI" and "Knarr-z3-no-global-hint" in place of "CONFETTI no global hints" - in our early experiments we also considered a variety of other system designs, Knarr-z3 was the design that eventually evolved into CONFETTI.

🕒 *Shorter run option* 🕒 The smallest experiment that will generate any meaningful results requires ~3 hours to run, and will execute 1 trial of each fuzzer on each fuzzing target, for 10 minutes each. You can run this shorter trial, and then use these results for the data processing pipelines to generate the tables and graphs. To run this experiment, run the command `./scripts/runSmokeTest.sh`. The results will be output to the directory `local_eval_output`. For other durations, you can edit the timeout in `runOneSmokeTest.sh` - it is specified in seconds through variable `DURATION`.

We saved a copy of the output of a successful run of this script to `tool_output/runSmokeTest.sh.out`, and the resulting fuzzing results to `prebake_shorter_fuzz_output`.

### Producing the tables and graphs from the results

**Configuration Notes** These scripts instructions, by default, process the primary data that we collected for our ICSE 2022 paper, which is stored in this artifact in the `icse_22_fuzz_output`. If you are following the 🕒 *Shorter run option* 🕒, the correct directory to specify is `local_eval_output`. The **fastest** way to run these scripts in their entirety is to use the 🎂 pre-baked 🕒 short run results (1 trial of each fuzzer for 10 minutes each, pre-collected), which are in the directory `prebake_shorter_fuzz_output`.

#### Table 1: Summary of results for RQ1 and RQ2: Branch coverage and bugs found
The left side of this table (branch coverage) is built by using the script `scripts/reproCorpusAndGetJacocoTGZ.php`.
This script takes as input the tgz archives of each of the results directories produced from the fuzzing campaign (e.g. the files in `icse_22_fuzz_output`) and automates the procedure of collecting branch coverage using JaCoCo.

To execute the script, run `php scripts/reproCorpusAndGetJacocoTGZ.php icse_22_fuzz_output` - note that our experience is that this script can take several hours to run. Note that due to non-determinism, we have noticed that the exact number of branches covered might vary by one or two on repeated runs.

🎂 *Pre-bake available* 🎂 The output of our run of this script is in `tool_output/reproCorpusAndGetJacocoTGZ.txt`, if you do not have an hour to wait for the results, consider inspecting this file directly. You might also run the script, which will print out results as it goes, and confirm that the first few numbers look OK and then terminate the script early before it computes the rest. 

🕒 *Shorter run option* 🕒 Collecting JaCoCo coverage from the 10 minute trials takes approximately 5-10 minutes. To collect the coverage, run `php scripts/reproCorpusAndGetJacocoTGZ.php local_eval_output`. 


The right side of this table (bugs found) is built by manually inspecting the failures detected by each fuzzer, de-duplicating them, and reporting them to developers. 
The failures are collected from the `fuzz_output` directory and processed by a de-duplicating script.
Our de-duplicating script uses a stacktrace heuristic to de-duplicate bugs. CONFETTI itself has some de-duplication features within the source code, but JQF+Zest has minimal, resulting in many of the same issues being saved. 
Our simple heuristic is effective at de-duplicating bugs (particularly in the case of JQF+Zest and Closure, which de-duplicates thousands of failures to single digits). 
However, some manual analysis is still needed, as a shortcoming of a stack analysis heuristic is that two crashes may share the same root cause, despite manifesting in different ways. 

Once you have a fuzzing corpus (e.g. from a local run that you completed, or using the 🎂 pre-bake results🎂 ), you may perform the de-duplication by running `scripts/unique.py` as follows

`python3 scripts/unique.py fuzzOutputDir outputDirectory`

For example, to analyze the fuzzing corpus that we reported on in our ICSE 22 paper and save the output to `bugs`, run the command  `python3 scripts/unique.py icse_22_fuzz_output bugs`.
The failures within the tarball will be de-duplicated and the `bugs` directory will create a directory hierarchy corresponding to the target+fuzzer, the bug class, and the trials which found that bug. 
The de-duplication script will also print the number of unique bugs (according to our heuristic) that were found for each target+fuzzer configuration.
Please keep in mind that running the de-duplication script could take several hours, as there are thousands of failures per run (particularly in Closure and Rhino) that require de-duplication.
We conducted manual analysis by examining the output directories from this script to determine if the unique bugs were or were not attributed to the same root cause. 
The result of the manual analysis is shown in Tables 1 and 2 in the paper.


🎂 *Pre-bake available* 🎂 The entire de-duplication script will take several hours to run. However, we have included a pre-run output directory located at `prebake_icse_22_bugs`. This directory is organizd by fuzzer+target, and subdirectories of failure hashes that the de-duplication script deemed to be unique. This directory is what we based our manual analysis upon.

🕒 *Shorter run option* 🕒 The de-duplicating script finishes in a matter of seconds on the 10 minute experiment, you can run it by passing either the `prebake_shorter_fuzz_output` to use our 🎂 pre-bake 3-hour results 🎂, or `local_fuzz_output` if you ran your own campaign.

### Figure 3: Graphs of branch coverage over time
These graphs are generated in two steps:

1. Generate CSV files that contain coverage over time for each fuzzing campaign. Run the script `php scripts/extract-coverage.php icse_22_fuzz_output generated-coverage`. The first argument can be changed to point to a different set of primary data (e.g. `local_eval_output`, or `prebake_shorter_fuzz_output`), and the second argument can be changed to put the output intermediate dat somewhere else (it is used in the next step). This script may take 30-45 minutes to run, as it needs to extract and process many large files: the fuzzer that we built atop logs statistics every 300 milliseconds, which adds up to quite a bit of data for these 24-hour runs. This script downsamples the data to a one-minute granularity.
    * 🎂 *Pre-bake available* 🎂 You can also skip directly to step 2: the VM is distributed with these files in place, in `prebake_icse_22_generated_coverage`.
2. Build the actual plots, using R: run `Rscript scripts/graphCoverage-fig2.R directoryGeneratedByStep1` (e.g. `Rscript scripts/graphCoverage-fig2.R prebake_icse_22_generated_coverage` (or `generated-coverage` if you re-computed this intermediate data). You can disregard the warning messages. 5 PDFs will be output to the current directory: `(ant,bcelgen,closure,maven,rhino)_branches_over_time.pdf`

**Noted divergence between script and submitted paper, correction in camera-ready**: The submitted paper mistakingly reports the bands on the graphs as a confidence interval. They are not, but are in fact a range between min-max values. We have updated this in the text for the camera ready, and do not believe it impacts any conclusions that one would have drawn from the figure, but note this distinction for the particular reviewer who compared the contents of this script with the text in the paper.

### Table 2: Bug detectability rate
This table is built based on the manual analysis of figures discussed above in the context of Table 1. A more detailed description of the bugs, along with a link to their respective issue tracker (where applicable for newly discovered bugs), is included in the table below. 

In order to properly compare against the state-of-the-art (JQF+Zest) we elected to test against the same version of software that the authors did, which was an earlier version than the most current release of the respective software at the time of publication. Becauses of this, some newly discovered bugs (N-Days) were unable to be replicated in the latest release of the respective target and were not reported to developers. However, all stacktraces are included in this artifact for completeness (as discussed in the Table 1 section above).

| Bug ID        | Target   |Description   | Status/ Issue Tracker Link|
| ------------- | ------------- |-------------------| -------------------|
| A1		  	| Apache Ant    |java.lang.IllegalStateException  |	Previously discovered by JQF+Zest |
| B1            | Apache BCEL   | org.apache.bcel.classfile.ClassFormatException  |	 Previously discovered by JQF+Zest				 | 
| B2            | Apache BCEL   | org.apache.bcel.verifier.exc.AssertionViolatedException  |	 Previously discovered by JQF+Zest				 |
| B3            | Apache BCEL   | java.lang.IllegalArgumentException  |	 Open Issue: https://issues.apache.org/jira/projects/BCEL/issues/BCEL-358			 | 
| B4            | Apache BCEL   | org.apache.bcel.verifier.exc.AssertionViolatedException  |	 Unreported, could not replicate in latest version				 |
| B5            | Apache BCEL   | java.lang.StringIndexOutOfBoundsException  |	 Open Issue: https://issues.apache.org/jira/browse/BCEL-357		 | 
| B6            | Apache BCEL   | org.apache.bcel.generic.ClassGenException  |	 Open Issue: https://issues.apache.org/jira/browse/BCEL-359				 |
| C1            | Google Closure   | java.lang.NullPointerException  |	Previously discovered by JQF+Zest		 | 
| C2            | Google Closure   | java.lang.NullPointerException  |	 Previously discovered by JQF+Zest				 |
| C3            | Google Closure   | java.lang.NullPointerException  				|	Previously discovered by JQF+Zest		 | 
| C4            | Google Closure   | java.lang.NullPointerException  |	 Closed (fixed) Issue: https://github.com/google/closure-compiler/issues/3455				 |
| C5            | Google Closure   | java.lang.NullPointerException  |	Closed (fixed) Issue: https://github.com/google/closure-compiler/issues/3375 (also https://github.com/google/closure-compiler/issues/3380)		 | 
| C6            | Google Closure   | java.lang.IllegalArgumentException  |	 Unreported, could not replicate in latest version				 |
| C7            | Google Closure   | java.lang.RuntimeException  |	Acknowledged Issue: https://github.com/google/closure-compiler/issues/3591		 | 
| C8            | Google Closure   |  java.lang.NullPointerException |	 Acknowledged Issue: https://github.com/google/closure-compiler/issues/3861				 |
| C9            | Google Closure   | java.lang.IllegalStateException  			|	Previously discovered by JQF+Zest		 | 
| C10           | Google Closure   | java.lang.RuntimException  |	 Unreported, could not replicate in latest version			 |
| C11           | Google Closure   | java.lang.IllegalStateException  |	Acknowledged Issue: https://github.com/google/closure-compiler/issues/3860 (also https://github.com/google/closure-compiler/issues/3858, https://github.com/google/closure-compiler/issues/3859 )	 | 
| C13           | Google Closure   | java.lang.IllegalStateException  |	Closed Issue: https://github.com/google/closure-compiler/issues/3857		 | 
| C16           | Google Closure   | java.lang.IllegalStateException  |	Unreported, could not replicate in latest version		 | 
| C17           | Google Closure   | java.lang.IllegalStateException  |	 Unreported, could not replicate in latest version				 |
| C18           | Google Closure   | java.lang.IllegalStateException  |	Unreported, could not replicate in latest version		 | 
| R1          | Mozilla Rhino   | java.lang.ClassCastException  |	Previously discovered by JQF+Zest		 | 
| R2           | Mozilla Rhino   | java.lang.IllegalStateException  |	Previously discovered by JQF+Zest		 | 
| R3           | Mozilla Rhino   | java.lang.VerifyError  |	Previously discovered by JQF+Zest		 | 
| R4           | Mozilla Rhino  | java.lang.NullPointerException  |	Previously discovered by JQF+Zest		 | 
| R5          | Mozilla Rhino   | java.lang.ArrayIndexOutOfBoundsException  |	Previously discovered by JQF+Zest		 | 
<!-- | C12           | Google Closure   | java.lang.IllegalStateException  |	 Closed Issue: https://github.com/google/closure-compiler/issues/3858				 | -->
<!-- | C14           | Google Closure   | java.lang.IllegalStateException  |	 Closed Issue: https://github.com/google/closure-compiler/issues/3859	 | -->
<!-- | C15           | Google Closure   | java.lang.IllegalStateException  |	 Closed Issue: https://github.com/google/closure-compiler/issues/3380			 | -->

### Table 3: Inputs generated by mutation strategy and Table 4: Analysis of all saved inputs with global hints

These two tables are generated by a single R script, `scripts/tabularize-forensics-tables3and4.R`, but there are several steps needed to generate the intermdiate data, as described below for tables 3 and 4.
The usage of this Rscript is: `Rscript scripts/tabularize-forensics-tables3and4.R fuzzStatsCSVFile forensicsOutputDir`, where `fuzzStatsCSVFile` is the name of the file output by `extract-last-line-of-fuzz-stats.php` (table 3 info below), and `forensicsOutputDir` is the output of `collectExtendedHintInfo.php` (table 4 info below).

🎂 *Pre-bake available* 🎂 You can run this script directly with the command `Rscript scripts/tabularize-forensics-tables3and4.R prebake_icse_22_fuzz_stats.csv prebake_icse_22_forensics` to use the same exact intermediate results that we used for our paper (latex tables will be output to stdout), or follow the instructions below to re-generate all of the data from an entirely new fuzzing campaign:

#### For Table 3:
Table 3 needs the collected statistics from each fuzzing run's `plot_data` file. Run the script `scripts/extract-last-line-of-fuzz-stats.php fuzzOutputDir outputFilename`, where `fuzzOutputDir` is the collected fuzzing results (e.g. `icse_22_fuzz_output`, `local_eval_output`, `prebake_shorter_fuzz_output`), and `outputFilename` is a name you choose to use as the input to become `fuzzStatsCSVFile` above.

For example, to process the ICSE 22 results, run `php scripts/extract-last-line-of-fuzz-stats.php icse_22_fuzz_output generatedFuzzStats.csv`. This is expected to take 5-10 minutes, depending on the speed of your machine: it needs to process all of the big `.tgz` files in the `icse_22_fuzz_output` directory. 

#### For Table 4:
This table presents the results of an experiment to attempt to reproduce each of the inputs that CONFETTI generated that had been interesting at the time that they were generated (that is, running the input resulted in new branch probes being covered), but without using the global hints. This experiment is very time-intensive, and we estimate that it takes approximately 5-10 days to run (we did not record the exact duration of the experiment since timing information was not relevant to the RQ). 

This experiment takes as input a fuzzing corpus (the inputs saved by the fuzzer), and outputs a `.forensics-1k.csv` file.

To run this experiment, run the command: `php scripts/collectExtendedHintInfo.php fuzzOutputDir forensicsOutputDir`, following the same conventions from the above scripts for setting `fuzzOutputDir`. There may be a considerable amount of output from this script. 🎂 *Pre-bake available* 🎂 The forensics files generated from our ICSE 22 experiment are in the `prebake_icse_22_forensics` directory. 

🕒 *Shorter run option* 🕒 Running this experiment on the 10 minute experiment dataset takes just a few minutes. To run it, execute the command `php scripts/collectExtendedHintInfo.php local_eval_output shorter_forensics_output` (use `prebake_shorter_fuzz_output` along with `prebake_shorter_forensics_output` if you didn't spend the 3 hours to generate the local_eval_output).

## Continous Integration Artifact
To support our continued maintenance of CONFETTI and to make easy for us and others to execute performance evaluations of CONFETTI, we have designed a GitHub Actions workflow that automatically executes the entire evaluation that is described in this artifact.
Frankly, we do not know what role such an artifact should play in artifact evaluation: the continuous integration workflow certainly makes CONFETTI easier to reuse, but it also includes significant coupling to GitHub Actions and our HPC cluster, which might make it more difficult for future researchers to use should either of those two resources dissapear.

We hope that this aspect of our artifact will be most useful in the immediate future, and provide our VM to support long-term replicability.
For example, we found this workflow extremely useful for preparing the [final pull request](https://github.com/rohanpadhye/JQF/pull/171) that we made to the JQF maintainers to resolve the performance issues that are discussed in section 5 (lines 1021-1026), as it was necessary to compare several design alternatives to find the best performing solution. You can find several such reports linked on that pull request, or view [one of the most recent reports](https://ci.in.ripley.cloud/logs/public/jon-bell/JQF/d4bdc3392ba1dffff8ab105a1876d3c0dee1bd9a/Gold%20evaluation%20-%2024%20hours,%2020%20trials/1703015546/1/site/). This report includes a comparison of two branches of JQF (`fast-collision-free-coverage` and `reporting-ci`), where `fast-collision-free-coverage` (`d4bdc3`) includes our performance fixes, and `reporting-ci` is the baseline version of JQF (modified only to be compatible with our CI infrastructure).

The results of this workflow can be found on our [neu-se/CONFETTI GitHub repository](https://github.com/neu-se/CONFETTI/actions).
Our [template workflow](https://github.com/neu-se/actions-workflow-jqf) defines the steps to conduct the evaluation, which is parameterized over the number of trials to conduct, the duration of each campaign, and the list of branches to include as comparisons in the final report.
The workflow consists of the following jobs:
1. `build-matrix` - Creates a JSON build matrix that outputs all of the fuzzing tasks to run, one for each desired repetition of each fuzz target
2. `run-fuzzer` - For each trial defined by `build-matrix`, `run-fuzzer` will run the fuzzer and archive the results. If provided with a server address and access token, the `run-fuzzer` task will also start a [telegraf monitoring agent](https://www.influxdata.com/time-series-platform/telegraf/), which will stream statistics from the machine running the fuzzer to a central database. We found this monitoring to be extremely useful to, for example, monitor overall machine memory usage, and visualize the aggregate performance of each fuzzing run while they were underway.
3. `repro-jacoco` - Collect all of the results from each of the fuzzing runs, and reproduce the entire fuzzing corpus with JaCoCo instrumentation in order to collect final branch coverage results
4. `build-site` - Builds an HTML and an MD report using the [jon-bell/fuzzing-build-site-action](https://github.com/jon-bell/fuzzing-build-site-action),

We are happy to execute this workflow on our infrastructure for researchers who make pull requests on CONFETTI, and we are also excited to work with maintainers of other tools (like [rohanpadhye's JQF](http://github.com/rohanpadhye/JQF/)) to bring continuous evaluation workflows into the wider community and develop best practices for their design and maintenance.

## Building and Running CONFETTI outside of this artifact
CONFETTI can also be built and run outside of this artifact VM. The README in [the CONFETTI git repo](https://github.com/neu-se/confetti) explains how. We have also archived this git repository directly in our [FigShare artifact](https://doi.org/10.6084/m9.figshare.16563776) to ensure long-term availability.

## Contact 
Please feel free to [open an issue on GitHub](https://github.com/neu-se/CONFETTI/issues) if you run into any issues with CONFETTI. For other matters, please direct your emails to [Jonathan Bell](mailto:jon@jonbell.net).

## License
CONFETTI is released under the BSD 2-clause license.
