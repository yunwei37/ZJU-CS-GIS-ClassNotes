#!/bin/bash

TESTS="tests/test_cases.txt"
CASES="tests/test_results.txt"

echo "tests start!"

test_numbers="$(wc -l < $TESTS)"
result_numbers="$(wc -l < $CASES)"
if [ $test_numbers -eq 0 ]; then
    echo "No test cases found!"
    exit 1
fi
if [ $test_numbers -ne $result_numbers ]; then
    echo "Test cases and results are not equal!"
    exit 1
fi

for i in `seq 1 $test_numbers` ; do
    cmd1="sed -n "$i"p $TESTS"
    test_case="$($cmd1)"
    result="$($test_case)"
    cmd2="sed -n "$i"p $CASES"
    test_result="$($cmd2)"
    if [ "$result" == "$test_result" ]; then
        echo "test $i passed!"
    else
        echo $result
        echo $test_result
        echo "test $i failed!"
    fi
done

echo "tests success!"
