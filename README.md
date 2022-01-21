# Artifact for CONFETTI: CONcolic Fuzzer Employing Taint Tracking Information
Fuzz testing (fuzzing) allows developers to detect bugs and vulnerabilities in code by automatically generating defect-revealing inputs. Most fuzzers operate by generating inputs for applications and mutating the bytes of those inputs, guiding the fuzzing process with branch coverage feedback via instrumentation.
Whitebox guidance (e.g., taint tracking or concolic execution) is sometimes integrated with coverage-guided fuzzing to help  cover tricky-to-reach branches that are guarded by complex conditions (so-called "magic values"). This integration typically takes the form of a targeted input mutation, for example placing particular byte values at a specific offset of some input in order to cover a branch. However, these dynamic analysis techniques are not perfect in practice, which can result in the loss of important relationships between input bytes and branch predicates, thus reducing the effective power of the technique.

CONFETTI introduces a new, surprisingly simple, but effective technique, *global hinting*, which allows the fuzzer to insert these interesting bytes not only at a targeted position, but in any position of any input. We implemented this idea in Java, creating CONFETTI, which uses both targeted and global hints for fuzzing. In an empirical comparison with two baseline approaches, a state-of-the-art greybox Java fuzzer and a version of CONFETTI without global hinting, we found that CONFETTI covers more branches and finds 15 previously unreported bugs, including 9 that neither baseline could find.

CONFETTI is a research prototype, but nonetheless, we have had success applying it to fuzz the open-source projects Apache Ant, BCEL and Maven, Google's  Closure Compiler, and Mozilla's Rhino engine.

## About this artifact
We provide an artifact of our development and evaluation of CONFETTI that contains all of our code, scripts, dependencies and results in a Virtual Machine image, which we believe will provide a stable reference to allow others to be sure that they can make use of our tool and results in the future. However, we recognize that there is a significant tension between an artifact that is "resuable" and one which is stable. In the context of the rapidly-evolving field of fuzzers, "reusable" is likely best signified by a repository and set of continuous integration workflows that allow other researchers to fork our repository, develop new functionality, and automatically conduct an evaluation. What is most "resuable," unfortuantely is likely not the most stable/reliable approach to ensure the continued access to this service perpetually, due to external dependencies (and hence also provide a fully self-contained VM). We make our "live" continuous integration artifact available [on GitHub](https://github.com/neu-se/CONFETTI), and have permanently archived our CI workflow and its components [on FigShare](https://doi.org/10.6084/m9.figshare.16563776). 

Reviewers of this artifact should:
* Have VirtualBox or VMWare available to run our VM. It requires 4 CPU cores, 32GB RAM, and the disk image is XXX GB.

Ideally, reviewers might also consider checking to see whether they can build and run CONFETTI directly on their local machines and run a short (3-5 minute) fuzzing campaign, to validate that this simpler development model is also possible. The requirements for running CONFETTI directly on a machine are:
* Mac OS X or Linux (we have tested extensively with Ubuntu, other versions are sure to work, but may require manually installing the correct [release of z3 version 4.6 for the OS](https://github.com/Z3Prover/z3))
* Have Java 8 installed, with the `JAVA_HOME` environmental variable configured to point to that Java 8 JDK
* Have Maven 3.x instaleld
* Have at least 16GB RAM

### A suggested path to evaluate this artifact
Our experimental results require an enormous quantity of computational resources to generate: there are 20 trials each of three fuzzers on 5 target applications, where each trial takes 24 hours. We do not expect reviewers to repeat this entire evalution.

For each of the tables and figures that appear in the paper, there are generally 2-3 scripts that get run:
1. A perhaps very-long running (24 hour+) script that collects some primary data
2. A perhaps shorter, but still longer running (10 minutes - 2 hours) script that processes the primary data into an intermediate representation
3. A very fast running script that proceses the intermediate data into the final results that appear in the paper

A downside to having multiple scripts is that there is no single script for you to run to re-do the entire experiment. However, given the CPU time needed for gathering primary data, we think that the extra steps are well-worth the benefits for ease of use, debugging, and extension.

We would suggest the following path through this artifact to evalaute it:
1. Follow the steps under [Producing the tables and graphs from the results](#producing-the-tables-and-graphs-from-the-results). In each subsection look for this "pre-bake" icon 🎂, which will draw your attention to where to start to generate the tables and graphs using our previously-copmuted intermediate results. This should allow you to traverse this entire document without needing to wait for any long running computation. You can validate that the results match (or nearly match; some parts remain non-deterministic due to timing, and expected deviations are noted where applicable)
2. Run a fuzzing campaign, starting from [Running a fuzzing campaign in the artifact](#running-a-fuzzing-campaign-in-the-artifact). The shortest campaign that will generate sufficient data to be used by the rest of the data procesing pipeline will run all 3 fuzzers on all 5 benchmarks for 10 minutes each, with no repeated trials. This should take 3 hours to run. Our instructions show how to run the exact configuration that we performed in the paper and included the pre-bake 🎂 results for (24 hours x 20 trials x 3 fuzzers x 5 benchmarks), but look for the 🕒 *three oclock symbol* 🕒, which will draw your attention to specific instructions for running a shorter experiment.
3. Browse our "live" development artifact: a [Continuous Integration workflow](#continous-integration-artifact) that uses our HPC resources to execute short (10 minutes x 5 trials x 5 benchmarks) evalautions on each revision of our repository, and optionally full-scale (24 hour x 20 trials x 5 benchmarks) fuzzing campaigns. We would be happy to trigger this GitHub Action to run on our CI workers if you submit a pull request. 

## The "traditional" artifact (VM)
In our [ICSE 2022 paper](https://jonbell.net/publications/CONFETTI), we evaluated JQF-Zest, CONFETTI, and a variant of CONFETTI with global hints disabled.
This section describes how to reproduce those experiments, and includes pointers to the logs and results produced from our evaluation.
Note that we imagine that for future development, it will be far easier to use the Continuous Integration process described in the prior section to conduct performance evaluations.
However, we did not implement that process until *after* submitting the ICSE 2022 paper, and hence, with the goal of reproducibility, describe the exact steps to reproduce those results.
We executed the evaluation reported in the paper on Amazon's EC2 service, using `r5.xlarge` instances, each with 32GB of RAM and 4 CPUs.
We executed our experiments in parallel by launching one VM for each run (e.g. 20 trials x 3 fuzzers x 5 benchmarks = 300 VMs for 24 hours), where each VM had the same configuration as this artifact VM.
We then collected the results from each of those VMs; all of these results are included inside of this artifact and are also directly available for download on our [FigShare artifact](https://doi.org/10.6084/m9.figshare.16563776).

We provide an Ubuntu 20 VM that contains the exact same versions of all packages that we used in our paper evaluation.
We provide a brief overview of the software contained in the artifact to help future researchers who may want to modify CONFETTI or any of its key dependencies.
We expect that this use-case (modifying the code, recompiling, and running it) will be best supported by our Continuous Integration artifact described above, but the VM provides the most resilience to bitrot, as it includes all external dependencies and can be executed without being connected to the internet.

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
To run a fuzzing campaign in the artifact, use the script `scripts/runExpInScreen.sh`, which takes a single parameter: the experiment to run.
The available experiments are: `ant-confetti`, `ant-confetti-no-global-hint`, `ant-jqf`, `bcelgen-confetti`, `bcelgen-confetti-no-global-hint`, `bcelgen-jqf`, `closure-confetti`, `closure-confetti-no-global-hint`, `closure-jqf`, `maven-confetti`, `maven-confetti-no-global-hint`, `maven-jqf`, `rhino-confetti`, `rhino-confetti-no-global-hint`, `rhino-jqf`. This script will run the specified experiment with a timeout of 24 hours, if you would liek it to terminate sooner, you can end it by typing control-C.

We have also included a script, `scripts/runOneExperiment.php`, that we used to automate running a fuzzing experiment in a "headless" mode, where the experiment runs for 24 hours, then copies the results to an Amazon S3 bucket, and then shuts down the VM. There is additional configuration necessary to use the script.

🎂 *Pre-bake available* 🎂 The results presented in our paper are the result of running each of these experiments 20 times for 24 hour each. We include the raw results produced by running our `scripts/runOneExperiment.php` script in the directory `icse_22_fuzz_output`.  You can also download these results direclty from our [FigShare artifact](https://doi.org/10.6084/m9.figshare.16563776), they are included int he archive `fuzz_output.tgz`. In these result files, note that the name "Knarr-z3" is used in place of "CONFETTI" and "Knarr-z3-no-global-hint" in place of "CONFETTI no global hints" - in our early experiments we also considered a variety of other system designs, Knarr-z3 was the design that eventually evolved into CONFETTI.

🕒 *Shorter run option* 🕒 The smallest experiment that will generate any meaningful results requires ~3 hours to run, and will execute 1 trial of each fuzzer on each fuzzing target, for 10 minutes each. You can run this shorter trial, and then use these results for the data processing pipelines to generate the tables and graphs.
**TODO - add script to do this here, and add notes below to make sure that the right results are being used **

### Producing the tables and graphs from the results

#### Table 1: Summary of results for RQ1 and RQ2: Branch coverage and bugs found
The left side of this table (branch coverage) is built by using the script `scripts/reproCorpusAndGetJacocoTGZ.php`.
This script takes as input the tgz archives of each of the results directories produced from the fuzzing campaign (e.g. the files in `icse_22_fuzz_output`) and automates the procedure of collecting branch coverage using JaCoCo.

To execute the script, run `php scripts/reproCorpusAndGetJacocoTGZ.php icse_22_fuzz_output` - note that our experience is that this script can take several hours to run. Note that due to non-determinism, we have noticed that the exact number of branches covered might vary by one or two on repeated runs.

🎂 *Pre-bake available* 🎂 The output of our run of this script is in `tool_output/reproCorpusAndGetJacocoTGZ.txt`, if you do not have an hour to wait for the results, consider inspecting this file directly. You might also run the script, which will print out resutls as it goes, and confirm that the first few numbers look OK and then terminate the script early before it computes the rest. 

The right side of this table (bugs found) is built by manually inspecting the failures detected by each fuzzer, de-duplicating them, and reporting them to developers.

**TODO: Include list of failures here**

### Figure 3: Graphs of branch coverage over time
These graphs are generated in two steps:
1. Generate CSV files that contain coverage over time for each fuzzing campaign. Run the script `scripts/extract-coverage.php`. The output is stored in the directory `generated/coverage`. This script may take 30-45 minutes to run, as it needs to extract and process many large files: the fuzzer that we built atop logs statistics every 300 milliseconds, which adds up to quite a bit of data for these 24-hour runs. This script downsamples the data to a one-minute granularity.
    * 🎂 *Pre-bake available* 🎂 You can also skip this step entirely: the VM is distributed with these files in place. If you would like to fetch these files 
2. Build the actual plots, using R: run `Rscript scripts/graphCoverage-fig2.R`. You can disregard the warning messages. 5 PDFs will be output to the current directory: `(ant,bcelgen,closure,maven,rhino)_branches_over_time.pdf`

### Table 2: Bug detectability rate
This table is built based on the manual analysis of figures discussed above in the context of Table 1. A more detailed description of the bugs, along with a link to their respective issue tracker (where applicable for newly discovered bugs), is included in the table below. 

In order to properly compare against the state-of-the-art (JQF+Zest) we elected to test against the same version of software that the authors did, which was an earlier version than the most current release of the respective software at the time of publication. Becauses of this, some newly discovered bugs (N-Days) were unable to be replicated in the latest release of the respective target and were not reported to developers. However, all stacktraces are included in this artifact for completeness.

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
| C5            | Google Closure   | java.lang.NullPointerException  |	Closed (fixed) Issue: https://github.com/google/closure-compiler/issues/3375		 | 
| C6            | Google Closure   | java.lang.IllegalArgumentException  |	 Unreported, could not replicate in latest version				 |
| C7            | Google Closure   | java.lang.RuntimeException  |	Acknowledged Issue: https://github.com/google/closure-compiler/issues/3591		 | 
| C8            | Google Closure   |  java.lang.NullPointerException |	 Acknowledged Issue: https://github.com/google/closure-compiler/issues/3861				 |
| C9            | Google Closure   | java.lang.IllegalStateException  			|	Previously discovered by JQF+Zest		 | 
| C10           | Google Closure   | java.lang.RuntimException  |	 Unreported, could not replicate in latest version			 |
| C11           | Google Closure   | java.lang.IllegalStateException  |	Acknowledged Issue: https://github.com/google/closure-compiler/issues/3860		 | 
| C12           | Google Closure   | java.lang.IllegalStateException  |	 Closed Issue: https://github.com/google/closure-compiler/issues/3858				 |
| C13           | Google Closure   | java.lang.IllegalStateException  |	Closed Issue: https://github.com/google/closure-compiler/issues/3857		 | 
| C14           | Google Closure   | java.lang.IllegalStateException  |	 Closed Issue: https://github.com/google/closure-compiler/issues/3859	
| C15           | Google Closure   | java.lang.IllegalStateException  |	 Closed Issue: https://github.com/google/closure-compiler/issues/3380			 |
| C16           | Google Closure   | java.lang.IllegalStateException  |	Unreported, could not replicate in latest version		 | 
| C17           | Google Closure   | java.lang.IllegalStateException  |	 Unreported, could not replicate in latest version				 |
| C18           | Google Closure   | java.lang.IllegalStateException  |	Unreported, could not replicate in latest version		 | 
| R1          | Mozilla Rhino   | java.lang.ClassCastException  |	Previously discovered by JQF+Zest		 | 
| R2           | Mozilla Rhino   | java.lang.IllegalStateException  |	Previously discovered by JQF+Zest		 | 
| R3           | Mozilla Rhino   | java.lang.VerifyError  |	Previously discovered by JQF+Zest		 | 
| R4           | Mozilla Rhino  | java.lang.NullPointerException  |	Previously discovered by JQF+Zest		 | 
| R5          | Mozilla Rhino   | java.lang.ArrayIndexOutOfBoundsException  |	Previously discovered by JQF+Zest		 | 


### Table 3: Inputs generated by mutation strategy and Table 4: Analysis of all saved inputs with global hints

These two tables are generated by a single R script, `scripts/tabularize-forensics-tables3and4.R`.

🎂 *Pre-bake available* 🎂 You can run this script directly with the command `RScript scripts/tabularize-forensics-tables3and4.R` to use the same exact intermediate results that we used for our paper (latex tables will be output to stdout), or follow the instructions below to re-generate all of the data from an entirely new fuzzing campaign:

#### For table 3:
* Collect the statistics from each fuzzing run's `plot_data` file. Run the script `scripts/extract-last-line-of-fuzz-stats.php`. This is expected to take 5-10 minutes, depending on the speed of your machine: it needs to process all of the big `.tgz` files in the `icse_22_fuzz_output` directory. The resulting file is `generated/fuzz_stats.csv`.

#### For table 4:
This table presents the results of an experiment to attempt to reproduce each of the inputs that CONFETTI generated that had been interesting at the time that they were generated (that is, running the input resulted in new branch probes being covered), but without using the global hints. This experiment is very time-intensive, and we estimate that it takes approximately 5-10 days to run (we did not record the exact duration of the experiment since timing information was not relevant to the RQ).

This experiment takes as input a fuzzing corpus (the inputs saved by the fuzzer), and outputs a `.forensics-1k.csv` file.

To run this experiment, run the command: `php scripts/collectExtendedHintInfo.php`. 🎂 *Pre-bake available* 🎂 The forensics files generated from our ICSE 22 experiment are in the `icse_22_fuzz_output` directory, and can also be retrieved directly from our artifact on FigShare, in the `forensics.tgz` file

## Continous Integration Artifact

**TODO - describe setup, include pointers to the scripts, put scripts on FigShare, add note here that the scripts for this are also on FigShare, then add this text to CONFETTI README, too**

## Contact 
Please feel free to [open an issue on GitHub](https://github.com/neu-se/CONFETTI/issues) if you run into any issues with CONFETTI. For other matters, please direct your emails to [Jonathan Bell](mailto:jon@jonbell.net).

## License
CONFETTI is released under the BSD 2-clause license.
