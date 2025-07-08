#!/bin/bash

set -e

echo "Running WGSL Tool Tests"
echo "======================="

# Build the project
echo "Building..."
cargo build --release

BINARY="./target/release/wgsl_analysis"
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local input_file="$2"
    local format="$3"

    echo -n "Testing $test_name... "

    if [ ! -f "$input_file" ]; then
        echo "SKIP (file not found)"
        return
    fi

    if $BINARY "$input_file" --format "$format" > /dev/null 2>&1; then
        echo "PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "FAIL"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Run tests
run_test "Simple WGSL" "examples/simple.wgsl" "wgsl"
run_test "Simple GLSL" "examples/simple.wgsl" "glsl"
run_test "Simple HLSL" "examples/simple.wgsl" "hlsl"
run_test "Simple Metal" "examples/simple.wgsl" "metal"
run_test "Simple SPIR-V" "examples/simple.wgsl" "spirv"

run_test "Multi-stage WGSL" "examples/multi_stage.wgsl" "wgsl"
run_test "Multi-stage GLSL" "examples/multi_stage.wgsl" "glsl"
run_test "Multi-stage HLSL" "examples/multi_stage.wgsl" "hlsl"
run_test "Multi-stage Metal" "examples/multi_stage.wgsl" "metal"
run_test "Multi-stage SPIR-V" "examples/multi_stage.wgsl" "spirv"

# Test error handling
echo -n "Testing error handling... "
if $BINARY "nonexistent.wgsl" > /dev/null 2>&1; then
    echo "FAIL (should have failed)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
else
    echo "PASS"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# Summary
echo
echo "===================="
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed."
    exit 1
fi
