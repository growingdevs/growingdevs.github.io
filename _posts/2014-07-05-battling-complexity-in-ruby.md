---
published: true
title: Battling Complexity in Ruby
subtitle:
author: Coraline Ada Ehmke
author_url: 'http://where.coraline.codes'
ga_id:
created_at: 2014-07-05 18:14:42.970907 -05:00
published_at: 2014-07-05 18:14:42.972664 -05:00
layout: post
tags: ruby, refactoring
summary: Refactoring code without determining metrics and success criteria in advance can be a recipe for disaster. Fukuzatsu is a new code analysis tool that can guide and measure the success of your refactoring efforts.
---

Every one of our classes is an ambitious creature that seeks power through an accumulation of methods; knowledge through willful ignorance of the Law of Demeter; freedom by resisting testability; immortality through complexity. In short, they all strive for godhood.

When this happens, we find the power relationship between the developer and the codebase inverted. The code controls us. We become mere handmaidens to complexity. Although our instinct might be to treat problems of complexity as Gordian knots to cut through with a single stroke of cleverness, this is a fantasy that almost never plays out well in reality. The truth is that achieving simplicity takes a lot of effort. Our best chance to win victory over complexity lies in our ability to slowly and methodically break complicated things down into smaller pieces.

# Code Analysis

Just as changing code without having tests as a guiderope is a recipe for disaster, so is refactoring code without deciding in advance on success criteria. One way to establish such criteria is through the use of code analysis tools.

The gallery of such tools is populated with evocatively-named rogues such as Flog, Flay, and Reek. Some, like Metric Fu, are meta-tools combining several analysis tools together to provide a more faceted view of code quality. And of course there is the SaaS solution of Code Climate, with its famous letter-grade ranking of complexity.

But the results of these tools can often be overwhelming. What do you do with the list of code smells, the failing grades, the cryptic numbers?

My recommendation is to start small. Identify a single metric that is easy to understand and communicate, and take steps to improve that metric.

# If Only

It helps to define boundaries and sharpen our focus. A good first pass at reducing complexity can be to refactor conditional-heavy methods. The wedge code that most often undermines the simplicity, reusability, and clarity of our programs is the conditional. (A tax on `if` statements, with extra penalties for ternaries, would do more for code quality than an army of consultants equipped with Michael Feathers books.)

Reducing conditionals is a good way to reduce noise in the codebase, and reveal more gnarly complexity underneath, while making positive and demonstrable progress in promoting code clarity.

# The Garden of Plenty

There are lots of code analysis tools that measure complexity, but none of them seem to agree on what complexity means. Running a suite of analysis tools using (MetricFu)[https://github.com/metricfu/metric_fu] can demonstrate general consensus on where hotspots in the code are, but it's easy to be overwhelmed by the half-dozen independent metrics that component tools provide. It's also impossible to compare the results of one tool against another, because each uses independent metrics and algorithms. Is a "D" in Code Climate better or worse than an 13.2 in Flay? Once again we face a signal-to-noise problem.

Surely there is a tool that specifically helps identify overuse of conditionals?

# The Desert of the Real

The best approach to identifying complex conditional logic is examining cyclomatic complexity scores. Cyclomatic complexity is derived from an analysis of the number of possible execution paths through a given piece of code. There is even a Ruby tool for measuring this, called Saikuro, and it's already part of MetricFu.

Unfortunately the output of the program didn't serve my needs. I forked the repository with the intention of extending the program to produce output that I could better use. I discovered that the project was created in 2005 and appeared to be abandoned. The version that MetricFu used was a bespoke fork. And the code had not aged well– despite my best efforts, I found the program to be (ironically) complex and resistant to change.

# Fukuzatsu is Born

I promise that I did not set out from the start to build my own code complexity tool. Really I didn't. But in the end, that's what I did.

Fukuzatsu (Japanese for "complexity") is a command-line tool packaged as a Ruby gem. It is invoked by the `fuku check` command, which takes a file path as an argument. Output options can be specified by a `--format` (or `-f`) flag, and include `html`, `csv`, and of course `text` (default). An early feature request resulted in one other output mode, designed for CLI integration, which returns a zero or non-zero exit status based on the target code staying below a user-provided complexity threshold (specified with a `--threshold` or `-t` option).

## STDOUT Output

Good UNIX programs accept text input and return text output, allowing them to be used in the composition of powerful ad-hoc programs using the `|`. Fukuzatsu's default mode accepts a file path and returns text output. So for example if we want to analyze the largest file in our project, we can do this:

    $ ls -S ./lib/*/** | head -1 | xargs fuku check $1

This composite program uses `ls` to list files in order of size, piped to `head` to grab the first on the list, and passing the result to `fuku` for analysis. The output is:

    Analyzer    17
    Analyzer  #initialize 0
    Analyzer  #complexity 1
    Analyzer  #extract_methods  1
    Analyzer  #extract_class_name 2
    Analyzer  #text_at  0
    Analyzer  #find_class 4
    Analyzer  #extend_graph 0
    Analyzer  #methods_from 4
    Analyzer  #parent_node? 1
    Analyzer  #parse! 1
    Analyzer  #parsed 1
    Analyzer  #traverse 2

This says that the overall complexity of the Analyzer class is 17. Each method is listed with its name and complexity value. This output is suitable for piping out to other programs, or to a file for later perusal:

    $ ls -S ./lib/*/** | head -1 | xargs fuku check $1 > results.txt

This could be handy for running via a cron job to measure how complexity changes over time.

## CSV Output

If you want to pull your analysis into a spreadsheet, the csv option is right for you:

    $ fuku check lib/foo/bar.rb
    Results written to:
    doc/fukuzatsu/lib/foo/bar.rb.csv

## CI Output

To better integrate with a continuous integration system, set the `-t` (threshold) flag with the maximum allowed complexity level:

    $ fuku check lib/fukuzatsu/complex.rb -t 7
    Complex   17
    Complex #initialize 0
    Complex #complexity 1
    Complex #extract_methods  1
    Complex #extract_class_name 2
    Complex #text_at  0
    Complex #find_class 4
    Complex #extend_graph 0
    Complex #methods_from 4
    Complex #parent_node? 1
    Complex #parse! 1
    Complex #parsed 1
    Complex #traverse 2

    Results written to:
    doc/fukuzatsu/lib/fukuzatsu/complex.rb

    Maximum complexity is 17, which is greater than the threshold of 7.

When a threshold is set, the return value will be non-zero if the threshold is met or exceeded.

## HTML Output

For an interactive report, use the `-f html` flag:

    $ fuku check lib/my_project/ -f html
    Results written to:
    doc/fukuzatsu/index.htm

This will generate a tree of HTML files under the `./doc/fukuzatsu` directory, complete with an index file at the root path. The generated pages display sortable and filterable tables of files or methods with their complexity values.

# Wrapping Up

I'm finding Fukuzatsu to be a great tool for helping me identify complexity resulting from too many conditionals in my code. In fact, I use it regularly to measure itself and try to keep the numbers from going up from merge request to merge request.

I hope that you'll check out Fukuzatsu and try it in your refactoring project. And of course bug reports, feature requests, and merge requests are always welcome! It's available on RubyGems right now (`gem install fukuzatsu`), and installation and usage instructions are provided on  [GitLab](https://gitlab.com/coraline/fukuzatsu/tree/master).
