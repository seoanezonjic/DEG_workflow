#! /usr/bin/env Rscript

library(optparse)

########################################################################
## OPTPARSE
########################################################################
option_list <- list(
    make_option(c("-d", "--data"), type="character",
                help="Star Log File as input")
)
opt <- parse_args(OptionParser(option_list=option_list))

########################################################################
## MAIN
########################################################################
lines <- readLines(opt$data)
# Separate based on | and only get cases where we have a successful split into 2
split_lines <- sapply(lines, function(x) strsplit(x, "\\|"))
split_lines <- split_lines[sapply(split_lines, length) == 2]
# Returns as table and with whitespace trimmed
clean_split_lines <- lapply(split_lines, trimws)
# Change spaces to _ for the variable names only
clean_split_lines <- lapply(split_lines, function(x) {
    x <- trimws(x)
    x <- gsub(" ", "_", x)
    return(x)
    }
)
invisible(
	lapply(clean_split_lines, function(x) cat(x[1], "\t", x[2], "\n"))
)