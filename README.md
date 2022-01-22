# Artifact for CONFETTI: CONcolic Fuzzer Employing Taint Tracking Information
Fuzz testing (fuzzing) allows developers to detect bugs and vulnerabilities in code by automatically generating defect-revealing inputs. Most fuzzers operate by generating inputs for applications and mutating the bytes of those inputs, guiding the fuzzing process with branch coverage feedback via instrumentation.
Whitebox guidance (e.g., taint tracking or concolic execution) is sometimes integrated with coverage-guided fuzzing to help  cover tricky-to-reach branches that are guarded by complex conditions (so-called "magic values"). This integration typically takes the form of a targeted input mutation, for example placing particular byte values at a specific offset of some input in order to cover a branch. However, these dynamic analysis techniques are not perfect in practice, which can result in the loss of important relationships between input bytes and branch predicates, thus reducing the effective power of the technique.

CONFETTI introduces a new, surprisingly simple, but effective technique, *global hinting*, which allows the fuzzer to insert these interesting bytes not only at a targeted position, but in any position of any input. We implemented this idea in Java, creating CONFETTI, which uses both targeted and global hints for fuzzing. In an empirical comparison with two baseline approaches, a state-of-the-art greybox Java fuzzer and a version of CONFETTI without global hinting, we found that CONFETTI covers more branches and finds 15 previously unreported bugs, including 9 that neither baseline could find.

CONFETTI is a research prototype, but nonetheless, we have had success applying it to fuzz the open-source projects Apache Ant, BCEL and Maven, Google's  Closure Compiler, and Mozilla's Rhino engine.

## About this artifact
We provide an artifact of our development and evaluation of CONFETTI that contains all of our code, scripts, dependencies and results in a Virtual Machine image, which we believe will provide a stable reference to allow others to be sure that they can make use of our tool and results in the future. However, we recognize that there is a significant tension between an artifact that is "resuable" and one which is stable. In the context of the rapidly-evolving field of fuzzers, "reusable" is likely best signified by a repository and set of continuous integration workflows that allow other researchers to fork our repository, develop new functionality, and automatically conduct an evaluation. A continuous integration artifact likely has an enormous number of external dependencies that are not possible to capture - such as the provisioning and configuration of the CI server itself. We make our "live" continuous integration artifact available [on GitHub](https://github.com/neu-se/CONFETTI), and have permanently archived our CI workflow and its components [on FigShare](https://doi.org/10.6084/m9.figshare.16563776). 

Reviewers of this artifact should:
* Have VirtualBox or VMWare available to run our VM. It requires 4 CPU cores, 32GB RAM, and the disk image is XXX GB.

Ideally, reviewers might also consider checking to see whether they can build and run CONFETTI directly on their local machines and run a short (3-5 minute) fuzzing campaign, to validate that this simpler development model is also possible. The requirements for running CONFETTI directly on a machine are:
* Mac OS X or Linux (we have tested extensively with Ubuntu, other versions are sure to work, but may require manually installing the correct [release of z3 version 4.6 for the OS](https://github.com/Z3Prover/z3))
* Have Java 8 installed, with the `JAVA_HOME` environmental variable configured to point to that Java 8 JDK
* Have Maven 3.x instaleld
* Have at least 16GB RAM

## The "traditional" artifact (VM)
In our [ICSE 2022 paper](https://jonbell.net/publications/CONFETTI), we evaluated JQF-Zest, CONFETTI, and a variant of CONFETTI with global hints disabled.
This section describes how to reproduce those experiments, and includes pointers to the logs and results produced from our evaluation.
Note that we imagine that for future development, it will be far easier to use the Continuous Integration process described in the prior section to conduct performance evaluations.
However, we did not implement that process until *after* submitting the ICSE 2022 paper, and hence, with the goal of reproducibility, describe the exact steps to reproduce those results.
We executed the evaluation reported in the paper on Amazon's EC2 service, using `r5.xlarge` instances, each with 32GB of RAM and 4 CPUs.

We provide an Ubuntu 20 VM that contains the exact same versions of all packages that we used in our paper evaluation.
We provide a brief overview of the software contained in the artifact to help future researchers who may want to modify CONFETTI or any of its key dependencies.
We expect that this use-case (modifying the code, recompiling, and running it) will be best supported by our Continuous Integration artifact described above, but the VM provides the most resilience to bitrot, as it includes all external dependencies and can be executed without being connected to the internet.

The artifact contains a suitable JVM, OpenJDK 1.8.0_312, installed to `/usr/lib/jvm/java-8-openjdk-amd64/`. The CONFETTI artifact is located in `/home/icse22ae/confetti-artifact`, and contains compiled versions of all dependencies. The artifact directory contains scripts to run the evaluation, and we include the source code of all of CONFETTI's key components, which can be modified and built without connecting to the internet to fetch any additional dependencies. These projects can be re-built by running the `scripts/build-all.sh` or `scripts/build/[project].sh` script.

The key software artifacts are located in the `software` directory of the artifact:
* `jqf`: CONFETTI (named `jqf` for historical purposes), specifically [neu-se/confetti](https://github.com/neu-se/confetti)`@icse-22-evaluation` - The revision of CONFETTI that we evaluated
* `jqf-vanilla`: The baseline version of JQF we compared to, specifically [neu-se/jqf-non-colliding-coverage](https://github.com/neu-se/jqf-non-colliding-coverage)`@jqf-1.1-with-non-colliding-coverage`. See discussion of patches we wrote for JQF below.
* `knarr`: [gmu-swe/knarr](https://github.com/gmu-swe/knarr)`@icse-22-confetti-evaluation` - The constraint tracking runtime used by CONFETTI
* `green`: [gmu-swe/green-solver](https://github.com/gmu-swe/green-solver)
* `jacoco-fix-exception-after-branch`: [neu-se/jacoco](https://github.com/neu-se/jacoco/)`@fix-exception-after-branch` - Patched version of JaCoCo that we used to collect coverage. We found that JaCoCo wouldn't record a branch edge as covered if it was covered, and then immediately after an exception was thrown. This complicated debugging and analysis of the JaCoCo HTML output reports; this branch has that bug fixed, and it is this version of JaCoCo that is included in the artifact, and in the `software/jqf/jacoco-jars` directory.
* `software/z3`: Binaries from [Z3Prover/z3](https://github.com/Z3Prover/z3), release version 4.6.0-x64-ubuntu-16.04. The version of Z3 that we used in our evaluation.

Other software installed in the VM to support running the experiment scripts are:
* SSH server: we find it easiest to run VSCode outside of the VM, and use the "connect to remote" feature to connect your local VSCode instance to the artifact
* R: Plots and tables are generated using R. Installed packages include `readr, tidyr, plyr, ggplot2, xtable, viridis, fs, forcats`
* PHP: Some of our experiment scripts are written in PHP 


**All commands below should be executed in the `confetti-artifact` directory**

### Running a fuzzing campaign in the artifact
To run a fuzzing campaign in the artifact, use the script `scripts/runExpInScreen.sh`, which takes a single parameter: the experiment to run.
The available experiments are: `ant-confetti`, `ant-confetti-no-global-hint`, `ant-jqf`, `bcelgen-confetti`, `bcelgen-confetti-no-global-hint`, `bcelgen-jqf`, `closure-confetti`, `closure-confetti-no-global-hint`, `closure-jqf`, `maven-confetti`, `maven-confetti-no-global-hint`, `maven-jqf`, `rhino-confetti`, `rhino-confetti-no-global-hint`, `rhino-jqf`. This script will run the specified experiment with a timeout of 24 hours, if you would liek it to terminate sooner, you can end it by typing control-C.

We have also included a script, `scripts/runOneExperiment.php`, that we used to automate running a fuzzing experiment in a "headless" mode, where the experiment runs for 24 hours, then copies the results to an Amazon S3 bucket, and then shuts down the VM. There is additional configuration necessary to use the script.

The results presented in our paper are the result of running each of these experiments 20 times for 24 hour each.
We include the raw results produced by running our `scripts/runOneExperiment.php` script in the directory `icse_22_fuzz_output`.
In these result files, note that the name "Knarr-z3" is used in place of "CONFETTI" and "Knarr-z3-no-global-hint" in place of "CONFETTI no global hints" - in our early experiments we also considered a variety of other system designs, Knarr-z3 was the design that eventually evolved into CONFETTI.

### Producing the tables and graphs from the results

#### Table 1: Summary of results for RQ1 and RQ2: Branch coverage and bugs found
The left side of this table (branch coverage) is built by using the script `scripts/reproCorpusAndGetJacocoTGZ.php`.
This script takes as input the tgz archives of each of the results directories produced from the fuzzing campaign (e.g. the files in `icse_22_fuzz_output`) and automates the procedure of collecting branch coverage using JaCoCo.
To execute the script, run `php scripts/reproCorpusAndGetJacocoTGZ.php icse_22_fuzz_output` - note that our experience is that this script can take an hour to run. Expected output is shown in the file `tool_output/reproCorpusAndGetJacocoTGZ.txt`. Note that due to non-determinism, we have noticed that the exact number of branches covered might vary by one or two on repeated runs.

The right side of this table (bugs found) is built by manually inspecting the failures detected by each fuzzer, de-duplicating them, and reporting them to developers. 
We have included a tarball of all failures for the 20 run trials included in the CONFETTI paper at the following URL **TODO INCLUDE THE URL**, as well as our de-duplicating script. 
Our de-duplicating script uses a stacktrace heuristic to de-duplicate bugs. CONFETTI itself has some de-duplication features within the source code, but JQF+Zest has minimal, resulting in many of the same issues being saved. 
Our simple heuristic is effective at de-duplicating bugs (particularly in the case of JQF+Zest and Closure, which de-duplicates thousands of failures to single digits). 
However, some manual analysis is still needed, as a shortcoming of a stack analysis heuristic is that two crashes may share the same root cause, despite manifesting in different ways. 

Before running the de-duplication script, ensure that you have Python 3 installed on your machine. 
You may access the tarball of failures from the CONFETTI experiments by downloading them from the following URL: **TODO URL**.
Afterwards, you may perform the de-duplication by running `scripts/unique.py` as follows

`python3 scripts/unique.py /path/to/failures.tgz`

This will create a directory within the `scripts/` directory called `bugs`. 
The failures within the tarball will be de-duplicated and the `bugs` directory will create a directory hierarchy corresponding to the target+fuzzer, the bug class, and the trials which found that bug. 
The de-duplication script will also print the number of unique bugs (according to our heuristic) that were found for each target+fuzzer configuration.
Please keep in mind that running the de-duplication script could take several hours, as there are thousands of failures per run (particularly in Closure and Rhino) that require de-duplication.
We conducted manual analysis by examining the output directories from this script to determine if the unique bugs were or were not attributed to the same root cause. 
The result of the manual analysis is shown in Tables 1 and 2 in the paper.

### Figure 3: Graphs of branch coverage over time
These graphs are generated in two steps:
1. Generate CSV files that contain coverage over time for each fuzzing campaign. Run the script `scripts/extract-coverage.php`. The output is stored in the directory `generated/coverage`. This script may take 30-45 minutes to run, as it needs to extract and process many large files: the fuzzer that we built atop logs statistics every 300 milliseconds, which adds up to quite a bit of data for these 24-hour runs. This script downsamples the data to a one-minute granularity. You can also skip this step: the VM is distributed with these files in place
2. Build the actual plots, using R: run `Rscript scripts/graphCoverage-fig2.R`. You can disregard the warning messages. 5 PDFs will be output to the current directory: `(ant,bcelgen,closure,maven,rhino)_branches_over_time.pdf`

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


### Table 3: Inputs generated by mutation strategy

### Table 4: Analysis of all saved inputs with global hints
This table presents the results of an experiment to attempt to reproduce  

### Continous Integration Artifact

## Contact 
Please feel free to [open an issue on GitHub](https://github.com/neu-se/CONFETTI/issues) if you run into any issues with CONFETTI. For other matters, please direct your emails to [Jonathan Bell](mailto:jon@jonbell.net).

## License
CONFETTI is released under the BSD 2-clause license.