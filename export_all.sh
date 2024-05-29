#!/usr/bin/env bash

bash ./export.sh -asd && \
bash ./export.sh -asdo win32

# check exit code
retVal=${?}
if [[ $retVal -ne 0 ]]; then
	echo "export ERROR! Exit: ${retVal}"
	exit ${retVal}
else
	echo "export SUCCESS!"
fi
