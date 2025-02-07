#!/usr/bin/env python3

import os
import sys
import subprocess
import json

def run_cmake(build_dir, cmake_args):
    """Run the CMake command with the specified build directory and arguments."""
    os.makedirs(build_dir, exist_ok=True)

    # Request cmake's codemodel
    query_dir = os.path.join(build_dir, ".cmake", "api", "v1", "query")
    os.makedirs(query_dir, exist_ok=True)

    codemodel_file = os.path.join(query_dir, "codemodel-v2")
    open(codemodel_file, 'a').close()

    # Run cmake to get a file-api response
    cmake_command = ["cmake", "-B", build_dir] + cmake_args.split()
    try:
        subprocess.run(cmake_command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: CMake command failed with return code {e.returncode}", file=sys.stderr)
        sys.exit(e.returncode)

def parse_cmake_file_api(build_dir, summary_output):
    reply_dir = os.path.join(build_dir, ".cmake", "api", "v1", "reply")
    if not os.path.exists(reply_dir):
        print("Error: CMake File API reply directory not found.", file=sys.stderr)
        sys.exit(1)

    # Load all JSON files in the reply directory in a single file known at build time
    data = {}
    for filename in os.listdir(reply_dir):
        if filename.endswith(".json"):
            with open(os.path.join(reply_dir, filename), "r") as f:
                data[filename] = json.load(f)
    with open(summary_output, "w") as f:
        json.dump(data, f, indent=4)

def main(build_dir, cmake_args, summary_output):
    run_cmake(build_dir, cmake_args)
    parse_cmake_file_api(build_dir, summary_output)

if __name__ == "__main__":
    if len(sys.argv) < 7:
        print(f"Usage: {sys.argv[0]} --build_dir <build_directory> --cmake_args \"<CMake arguments>\" --summary_output <summary_output_file>", file=sys.stderr)
        sys.exit(1)

    build_dir = None
    cmake_args = None
    summary_output = None

    args = iter(sys.argv[1:])
    for arg in args:
        if arg == "--build_dir":
            build_dir = next(args, None)
        elif arg == "--cmake_args":
            cmake_args = next(args, None)
        elif arg == "--summary_output":
            summary_output = next(args, None)

    if not build_dir or not cmake_args or not summary_output:
        print(f"Usage: {sys.argv[0]} --build_dir <build_directory> --cmake_args \"<CMake arguments>\" --summary_output <summary_output_file>", file=sys.stderr)
        sys.exit(1)

    main(build_dir, cmake_args, summary_output)
