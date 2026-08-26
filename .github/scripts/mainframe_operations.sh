#!/bin/bash
# mainframe_operations.sh
# Setup environment
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH=$PATH:/usr/lpp/zowe/cli/node/bin

# Check Java availability
java -version

#Set ZOWE_USERNAME
ZOWE_USERNAME="$ZOWE_USERNAME"

# save directory before changing
REPO_ROOT=$(pwd)    
# Change to the cobolcheck directory
# cd cobol-check
echo "Changed to $(pwd)"
ls -al

# Make cobolcheck executable
##chmod +x cobolcheck
##echo "made cobolcheck executable"
ls -la bin

# Make script in scripts directory executable
# cd scripts
chmod +x linux_gnucobol_run_tests
echo "made linux_gnucobol:run_tests executable"
# cd ..

# Function to run cobolcheck and copy files
run_cobolcheck() {
  program=$1
  echo "running cobolcheck for $program"

  # Run cobolcheck, but don't exit if it fails
  ##./cobolcheck -p $program
  java -jar bin/cobol-check-0.2.19.jar -p $program
  echo "Cobolcheck execution completed for $program (exceptions may have occured)"

  # Check if CC##99.CBL was created, regardless of cobolcheck exit status
  if [ -f "testruns/CC##99.CBL" ]; then
    # copy to the mvs dataset
  #  if cp CC##99.CBL "//'${ZOWE_USERNAME}.CBL($program)'"; then
     if zowe zos-files ul ftds "testruns/CC##99.CBL" "${ZOWE_USERNAME}.CBL($program)"; then
      echo "copied CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)"
    else
      echo "failed to copy CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)"
    fi
  else
    echo "CC##99.CBL not found for $program"
  fi

  # Copy the JCL file if it exists
  # if [ -f "${program}.JCL" ]; then
  #   if cp ${program}.JCL "//'${ZOWE_USERNAME}.JCL($program)'"; then
  if [ -f "$REPO_ROOT/${program}.JCL" ]; then
    if zowe zos-files ul ftds $REPO_ROOT/${program}.JCL "${ZOWE_USERNAME}.JCL($program)"; then
      echo "Copied ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)"
    else
      echo "failed to copy ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)"
    fi
  else
    echo "${program}.JCL not found"
  fi
}

# Run for each program
for program in NUMBERS EMPPAY DEPTPAY; do
  run_cobolcheck $program
done

echo "Mainframe operations completed"
