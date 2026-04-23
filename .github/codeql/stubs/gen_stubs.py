#!/usr/bin/env python3
"""
Generate minimal Java stubs for CodeQL ql tests.

Builds a temporary CodeQL database from Maven source, runs
  codeql/java-queries:utils/stub-generator/MinimalStubsFromSource.ql
via `codeql database run-queries`, then post-processes the result into
stub .java files suitable for use as test classpath stubs.

Usage:
    gen_stubs.py <test_dir> <stub_dir> [pom.xml] [--codeql PATH] [--verify]
"""

import re
import sys
import subprocess
import json
import shlex
import shutil
import tempfile
import argparse
from pathlib import Path

STUB_QUERY = "codeql/java-queries:utils/stub-generator/MinimalStubsFromSource.ql"
BQRS_RESULT = Path(
    "results/codeql/java-queries/utils/stub-generator/MinimalStubsFromSource.bqrs"
)

_ARRAY_TYPE = re.compile(r"^[\w.<>?,\s]+\[\s*\]$")
_ANNOTATION_ELEMENT = re.compile(
    r"^(\s+)([\w][\w<>\[\],?\s]*?)\s+(\w+)\(\)\s*;$", re.MULTILINE
)


def _annotation_default(type_name: str) -> str | None:
    t = type_name.strip()
    if t == "String":
        return '""'
    if t == "boolean":
        return "false"
    if t in ("byte", "short", "int", "long", "float", "double", "char"):
        return "0"
    if _ARRAY_TYPE.match(t):
        return "{}"
    return None


def fix_annotation_defaults(content: str) -> str:
    """Add missing `default` values to annotation element declarations.

    The stub generator omits defaults (bytecode doesn't preserve them), which
    causes javac to reject annotation usages that omit those elements.
    """
    if "@interface" not in content:
        return content

    def replacer(m: re.Match) -> str:
        indent, type_name, element = m.group(1), m.group(2), m.group(3)
        default = _annotation_default(type_name)
        if default is None:
            return m.group(0)
        return f"{indent}{type_name} {element}() default {default};"

    return _ANNOTATION_ELEMENT.sub(replacer, content)


def run(cmd: list, *, check: bool = True) -> subprocess.CompletedProcess:
    print(f"\n$ {shlex.join(str(c) for c in cmd)}")
    result = subprocess.run(cmd)
    if check and result.returncode != 0:
        sys.exit(f"Command failed (exit {result.returncode})")
    return result


def print_javac_errors(db_dir: Path) -> None:
    logs = list(db_dir.glob("log/javac-output*"))
    if not logs:
        return
    print("\n--- javac output ---")
    with open(logs[0]) as f:
        for line in f:
            b1 = line.find("]")
            b2 = line.find("]", b1 + 1)
            print(line[b2 + 2:], end="")
    print("---")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate minimal Java stubs for CodeQL ql tests",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("test_dir", help="Test directory with .java and .ql/.qlref files")
    parser.add_argument("stub_dir", help="Output directory for generated stubs")
    parser.add_argument("pom_xml", nargs="?", help="pom.xml for Maven-based extraction (recommended)")
    parser.add_argument("--codeql", default="codeql", metavar="PATH", help="codeql binary (default: codeql)")
    parser.add_argument("--verify", action="store_true", help="Run test verification after stub generation")
    args = parser.parse_args()

    test_dir = Path(args.test_dir).resolve()
    stub_dir = Path(args.stub_dir).resolve()
    codeql = args.codeql

    if not test_dir.is_dir():
        sys.exit(f"Error: test directory not found: {test_dir}")
    if not list(test_dir.rglob("*.java")):
        sys.exit(f"Error: no .java files in {test_dir}")
    if not list(test_dir.rglob("*.ql")) + list(test_dir.rglob("*.qlref")):
        sys.exit(f"Error: no .ql/.qlref files in {test_dir}")

    stub_dir.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="codeql-stubs-") as work_str:
        work_dir = Path(work_str)
        project_dir = work_dir / "project"
        db_dir = work_dir / "db"

        # --- assemble source tree ---
        if args.pom_xml:
            pom_path = Path(args.pom_xml).resolve()
            if not pom_path.is_file():
                sys.exit(f"Error: pom.xml not found: {pom_path}")
            shutil.copytree(test_dir, project_dir / "src/main/java/test",
                            ignore=shutil.ignore_patterns("*.testproj"))
            shutil.copyfile(pom_path, project_dir / "pom.xml")
        else:
            shutil.copytree(test_dir, project_dir,
                            ignore=shutil.ignore_patterns("*.testproj"))

        # --- create database ---
        db_result = subprocess.run([
            codeql, "database", "create",
            "--language=java", f"--source-root={project_dir}", str(db_dir),
        ])
        if db_result.returncode != 0:
            print_javac_errors(db_dir)
            sys.exit("Error: codeql database create failed.")

        # --- run stub generator query via pack reference ---
        run([codeql, "database", "run-queries", str(db_dir), STUB_QUERY])

        # --- decode the bqrs written by run-queries ---
        bqrs_file = db_dir / BQRS_RESULT
        json_file = work_dir / "output.json"
        run([
            codeql, "bqrs", "decode",
            str(bqrs_file), "--format=json", "--output", str(json_file),
        ])

        with open(json_file) as f:
            results = json.load(f)

        for (typ,) in results.get("noGeneratedStubs", {}).get("tuples", []):
            print(f"WARNING: no stub generated for {typ}")
        for (typ,) in results.get("multipleGeneratedStubs", {}).get("tuples", []):
            print(f"WARNING: multiple stubs for {typ}, picking one arbitrarily")

        written = []
        for typ, stub_content in results.get("#select", {}).get("tuples", []):
            stub_file = stub_dir.joinpath(*typ.split(".")).with_suffix(".java")
            stub_file.parent.mkdir(parents=True, exist_ok=True)
            stub_file.write_text(fix_annotation_defaults(stub_content))
            written.append(typ)

        print(f"\nGenerated {len(written)} stub(s) in {stub_dir}")
        for t in sorted(written):
            print(f"  {t}")

    # --- verify ---
    if not args.verify:
        print("\nSkipping verification (pass --verify to enable).")
    else:
        print("\nVerifying stubs by running the test...")
        verify = subprocess.run([codeql, "test", "run", str(test_dir)])
        if verify.returncode != 0:
            for proj in test_dir.glob("*.testproj"):
                print_javac_errors(proj)
            print(
                "\nVerification failed. Possible causes:\n"
                "  1. The options file does not point to stub_dir\n"
                "  2. Generated stubs are incomplete — add missing types manually\n"
                "  3. The .expected file is out of date"
            )
            sys.exit(1)
        print("Verification passed!")

    print("\nDone.")


if __name__ == "__main__":
    main()
