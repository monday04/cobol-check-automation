#!/bin/bash
# zowe_operations.sh
# Create zowe profile
echo "Creating zowe Profile"
set -x
zowe config list
printf '%s' "$ZOWE_CONFIG_JSON" > zowe.config.json
zowe config set profiles.project_base.user "$ZOWE_USERNAME"
zowe config set profiles.project_base.password "$ZOWE_PASSWORD"
zowe zosmf check status

# Convert username to lowercase
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# Check if directory exists, create if not
if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" &>/dev/null; then
  echo "Directory does not exists. Creating it..."
  zowe zos-files create uss-directory /z/$LOWERCASE_USERNAME/cobolcheck
else
  echo "Directory already exists."
fi

# Upload files
zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive --binary-files "cobol-check-0.2.9.jar"

# Verify upload
echo "Verifying upload:"
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck"
