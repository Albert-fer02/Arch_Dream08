#!/bin/bash
# Silent bash execution script
LANG=C.utf8 LC_ALL=C.utf8 exec bash 2> >(grep -v "setlocale" >&2)
