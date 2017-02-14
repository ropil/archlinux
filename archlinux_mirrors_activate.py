#!/usr/bin/env python3
from re import compile

# Library functions
def read_mirrors(infile):
    mcountry = compile("^## \S+")
    mmirror = compile("^#Server = \S+")
    mirrors = {}
    country = None
    for line in infile:
        if mcountry.match(line):
            country = line.split()[1]
            mirrors[country] = []
        elif mmirror.match(line) and country is not None:
            mirrors[country].append(line.split("=")[-1].strip())
    return mirrors


def print_mirrors(mirrors, countries):
    for country in countries:
        print("# " + country)
        for mirror in mirrors[country]:
            print("Server = " + mirror)


def parse_countries(definition):
    return [country for country in definition.split(",")]

# Main; for callable scripts
def main():
    from argparse import ArgumentParser
    from sys import argv, stdin
    parser = ArgumentParser(
        description="Parse mirrorlist.pacnew.")
    parser.add_argument(
        "-c", nargs=1, metavar="country1[,country2[...]]",
        help="Comma separated list of countries to enable")
    parser.add_argument(
        "files", nargs="*", metavar="FILE", help="mirrorlist.pacnew to parse")
    arguments = parser.parse_args(argv[1:])
    files = arguments.files
    # Use stdin if no supplied files
    if len(arguments.files) == 0:
        files = [stdin]

    # Set variables here
    countries = parse_countries(arguments.c[0])
    mirrors = {}

    # Parse STDIN or files
    for f in files:
        infile = f
        # Open for reading if file path specified
        if isinstance(f, str):
            infile = open(f, 'r')
        mirrors = read_mirrors(infile)
        infile.close()

    print_mirrors(mirrors, countries)


if __name__ == '__main__':
    main()