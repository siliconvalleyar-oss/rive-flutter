---
name: bump-version
description: Bump the version in the VERSION file by incrementing the patch number (0.0.1). Use ONLY when the user asks to bump, increment, or update the version.
---

# Bump Version

When asked to bump the version:

1. Read the current `VERSION` file
2. Parse the semver (e.g., `1.0.1`)
3. Increment the patch number by 1 (e.g., `1.0.1` → `1.0.2`)
4. Write the new version back to `VERSION`
5. Inform the user of the old and new version
