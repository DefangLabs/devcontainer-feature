#!/bin/bash

set -e

# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
check "defang version" bash -c "defang version | grep 'Defang CLI'"

# Report results
reportResults