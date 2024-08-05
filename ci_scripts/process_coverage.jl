"""
Coverage Report Generator

This script processes coverage data for specified folders and
generates (or appends to) an LCOV report.

Usage:
    julia process_coverage.jl <output_file> <folder1> [<folder2> ...]

Arguments:
    <output_file>  : Path to the output LCOV file
    <folder1> ...  : One or more folders to process for coverage data

Behavior:
1. Imports necessary coverage tools.
2. Processes each specified folder for coverage data.
3. Combines coverage data from all folders.
4. Writes the combined coverage data to an LCOV file.
5. Prints a summary of covered lines and total lines.

Example:
    julia process_coverage.jl coverage.info src test

Output:
    - Generates or appends to an LCOV file at the specified output path.
    - Prints a summary of coverage to the console.
"""

include("ensure_import.jl")
@ensure_using CoverageTools

outputfilename = ARGS[1]
folders = ARGS[2:end]
if isfile(outputfilename)
    orig_coverage = LCOV.readfile(outputfilename)
else
    orig_coverage = Vector{FileCoverage}()
end
coverage = vcat(orig_coverage, [process_folder(f) for f in folders]...)
for c in coverage
    if all(isnothing.(c.coverage))
        c.coverage .= 0
    end
end
LCOV.writefile(outputfilename, coverage)

covered_lines, total_lines = get_summary(coverage)
println("Covered lines: ", covered_lines)
println("  Total lines: ", total_lines)
