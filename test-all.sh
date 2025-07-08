#!/bin/bash

# Comprehensive test script for WGSL Analysis Tool
# Tests both CLI and WebAssembly functionality

set -e

echo "WGSL Analysis Tool - Comprehensive Test Suite"
echo "=============================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}: $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}: $2"
        ((TESTS_FAILED++))
    fi
}

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing $test_name... "

    if eval "$test_command" > /dev/null 2>&1; then
        print_result 0 "$test_name"
        return 0
    else
        print_result 1 "$test_name"
        return 1
    fi
}

# Check prerequisites
echo "Checking prerequisites..."
echo "------------------------"

# Check for Rust
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Error: Rust/Cargo not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Rust/Cargo found"

# Check for wasm-pack
if ! command -v wasm-pack &> /dev/null; then
    echo -e "${RED}Error: wasm-pack not found${NC}"
    echo "Install with: cargo install wasm-pack"
    exit 1
fi
echo -e "${GREEN}✓${NC} wasm-pack found"

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Warning: Node.js not found - skipping Node.js tests${NC}"
    NODE_AVAILABLE=false
else
    echo -e "${GREEN}✓${NC} Node.js found"
    NODE_AVAILABLE=true
fi

echo

# Test 1: Build CLI version
echo "Test 1: Building CLI version"
echo "----------------------------"
run_test "CLI build" "cargo build --features cli"

echo

# Test 2: Build WebAssembly versions
echo "Test 2: Building WebAssembly versions"
echo "-------------------------------------"
run_test "WASM web build" "wasm-pack build --target web --out-dir pkg --features wasm"
run_test "WASM bundler build" "wasm-pack build --target bundler --out-dir pkg-bundler --features wasm"
run_test "WASM nodejs build" "wasm-pack build --target nodejs --out-dir pkg-nodejs --features wasm"

echo

# Test 3: CLI functionality tests
echo "Test 3: CLI functionality tests"
echo "-------------------------------"

# Test basic compilation
run_test "CLI WGSL compilation" "cargo run --features cli -- examples/triangle.wgsl --format wgsl"
run_test "CLI GLSL compilation" "cargo run --features cli -- examples/triangle.wgsl --format glsl"
run_test "CLI HLSL compilation" "cargo run --features cli -- examples/triangle.wgsl --format hlsl"
run_test "CLI Metal compilation" "cargo run --features cli -- examples/triangle.wgsl --format metal"
run_test "CLI SPIRV compilation" "cargo run --features cli -- examples/triangle.wgsl --format spirv"

# Test verbose flag
run_test "CLI verbose flag" "cargo run --features cli -- examples/triangle.wgsl --format glsl --verbose"

# Test output specification
run_test "CLI output specification" "cargo run --features cli -- examples/triangle.wgsl --format glsl --output test_output.glsl"

# Test error handling
run_test "CLI non-existent file handling" "! cargo run --features cli -- nonexistent.wgsl --format glsl"

echo

# Test 4: WebAssembly functionality tests
if [ "$NODE_AVAILABLE" = true ]; then
    echo "Test 4: WebAssembly functionality tests"
    echo "---------------------------------------"

    # Test Node.js example
    run_test "Node.js basic example" "node examples/nodejs-example.js"

    # Test file compilation via Node.js
    run_test "Node.js file compilation" "node examples/nodejs-example.js examples/triangle.wgsl glsl"

    # Test different formats via Node.js
    run_test "Node.js HLSL compilation" "node examples/nodejs-example.js examples/triangle.wgsl hlsl"
    run_test "Node.js Metal compilation" "node examples/nodejs-example.js examples/triangle.wgsl metal"
    run_test "Node.js SPIRV compilation" "node examples/nodejs-example.js examples/triangle.wgsl spirv"

    echo
else
    echo "Test 4: WebAssembly functionality tests"
    echo "---------------------------------------"
    echo -e "${YELLOW}Skipped: Node.js not available${NC}"
    echo
fi

# Test 5: Output file verification
echo "Test 5: Output file verification"
echo "--------------------------------"

# Check if output files were created and are not empty
test_output_file() {
    local file="$1"
    local format="$2"

    if [ -f "$file" ] && [ -s "$file" ]; then
        print_result 0 "Output file $file ($format)"
        return 0
    else
        print_result 1 "Output file $file ($format)"
        return 1
    fi
}

# Generate test files
cargo run --features cli -- examples/triangle.wgsl --format wgsl --output test_triangle.wgsl > /dev/null 2>&1
cargo run --features cli -- examples/triangle.wgsl --format glsl --output test_triangle.glsl > /dev/null 2>&1
cargo run --features cli -- examples/triangle.wgsl --format hlsl --output test_triangle.hlsl > /dev/null 2>&1
cargo run --features cli -- examples/triangle.wgsl --format metal --output test_triangle.metal > /dev/null 2>&1
cargo run --features cli -- examples/triangle.wgsl --format spirv --output test_triangle.spv > /dev/null 2>&1

# Test output files
test_output_file "test_triangle.wgsl" "WGSL"
test_output_file "test_triangle.glsl" "GLSL"
test_output_file "test_triangle.hlsl" "HLSL"
test_output_file "test_triangle.metal" "Metal"
test_output_file "test_triangle.spv" "SPIR-V"

echo

# Test 6: Package structure verification
echo "Test 6: Package structure verification"
echo "--------------------------------------"

# Check WebAssembly package contents
test_wasm_package() {
    local dir="$1"
    local target="$2"

    if [ -d "$dir" ] && [ -f "$dir/wgsl_analysis.js" ] && [ -f "$dir/wgsl_analysis.wasm" ]; then
        print_result 0 "WASM package structure ($target)"
        return 0
    else
        print_result 1 "WASM package structure ($target)"
        return 1
    fi
}

test_wasm_package "pkg" "web"
test_wasm_package "pkg-bundler" "bundler"
test_wasm_package "pkg-nodejs" "nodejs"

echo

# Test 7: Error handling tests
echo "Test 7: Error handling tests"
echo "----------------------------"

# Test invalid WGSL syntax
echo "invalid wgsl syntax here" > invalid_test.wgsl
run_test "Invalid WGSL handling" "! cargo run --features cli -- invalid_test.wgsl --format glsl"

# Test invalid format
run_test "Invalid format handling" "! cargo run --features cli -- examples/triangle.wgsl --format invalid"

# Cleanup
rm -f invalid_test.wgsl

echo

# Test 8: Content validation
echo "Test 8: Content validation"
echo "--------------------------"

# Check that GLSL output contains expected content
if [ -f "test_triangle.glsl" ]; then
    if grep -q "gl_Position" test_triangle.glsl && grep -q "gl_VertexID" test_triangle.glsl; then
        print_result 0 "GLSL content validation"
    else
        print_result 1 "GLSL content validation"
    fi
fi

# Check that HLSL output contains expected content
if [ -f "test_triangle.hlsl" ]; then
    if grep -q "SV_Position" test_triangle.hlsl && grep -q "SV_VertexID" test_triangle.hlsl; then
        print_result 0 "HLSL content validation"
    else
        print_result 1 "HLSL content validation"
    fi
fi

# Check that Metal output contains expected content
if [ -f "test_triangle.metal" ]; then
    if grep -q "vertex_id" test_triangle.metal && grep -q "position" test_triangle.metal; then
        print_result 0 "Metal content validation"
    else
        print_result 1 "Metal content validation"
    fi
fi

echo

# Cleanup temporary files
echo "Cleaning up temporary files..."
rm -f test_triangle.* test_output.glsl triangle.* examples/triangle.glsl examples/triangle.hlsl examples/triangle.metal examples/triangle.spv

echo

# Final results
echo "Test Results Summary"
echo "==================="
echo -e "Total tests: $((TESTS_PASSED + TESTS_FAILED))"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    echo "The WGSL Analysis Tool is working correctly."
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed.${NC}"
    echo "Please check the output above for details."
    exit 1
fi
