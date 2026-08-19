#!/bin/bash
# zowe_operations.sh
# Create zowe profile
echo "Creating zowe Profile"
zowe profile create zosmf myprofile \
  --host "$ZOWE_HOST" \
  --port "$ZOWE_PORT" \
  --user "$ZOWE_USERNAME" \
  --password "$ZOWE_PASSWORD" \
  --reject-unauthorized false
echo "Profile created."

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
