#!/bin/bash

## Check TSR:
# openssl ts -verify -data ./doc.pdf -in doc.pdf.tsr  -CAfile ./cacert.pem -untrusted ./tsa.crt
## Print timestamp in TSR:
# openssl ts -reply -in {{path/to/file.tsr}} -text 

# --- Configuration ---
TSA_URL="https://freetsa.org/tsr"
VERIFY_TIMESTAMP=false
# Path to your TSA's certificate bundle and TSA certificate, if verification is enabled
#TSA_CA_BUNDLE_PATH="./cacert.pem"
#TSA_CRT="./tsa.crt"

if [[ -z "${DOCUMENT_SOURCE_PATH}" || ! -f "${DOCUMENT_SOURCE_PATH}" ]]; then
    echo "Error: DOCUMENT_SOURCE_PATH is not set or is not a valid file. Exiting." >&2
    exit 1
fi

TS_CERT_PATH="${DOCUMENT_SOURCE_PATH}.tsr"

if [[ -f "${TS_CERT_PATH}" ]]; then
    echo "Timestamp certificate already exists for ${DOCUMENT_SOURCE_PATH}, skipping." >&2
    exit 0
fi

set -e

echo "Timestamping script initiated for: ${DOCUMENT_SOURCE_PATH}"

REQUEST_FILE=$(mktemp)
openssl ts -query -data "${DOCUMENT_SOURCE_PATH}" -sha512 -no_nonce -out "${REQUEST_FILE}"

echo "Sending hash to TSA at ${TSA_URL}..."
RESPONSE_FILE=$(mktemp)

curl -s -L -o "${RESPONSE_FILE}" -H "Content-Type: application/timestamp-query" --data-binary "@${REQUEST_FILE}" "${TSA_URL}"

if ! openssl ts -reply -in "${RESPONSE_FILE}" -text > /dev/null 2>&1; then
    echo "Error: Received an invalid timestamp response from the TSA."
    rm "${REQUEST_FILE}" "${RESPONSE_FILE}"
    exit 1
fi

mv "${RESPONSE_FILE}" "${TS_CERT_PATH}"
echo "Successfully stored timestamp certificate at: ${TS_CERT_PATH}"

rm "${REQUEST_FILE}"

if [ "$VERIFY_TIMESTAMP" = true ]; then
    echo "Verifying timestamp..."
    if [ ! -f "$TSA_CA_BUNDLE_PATH" ]; then
        echo "Verification skipped: CA bundle not found at ${TSA_CA_BUNDLE_PATH}"
    elif openssl ts -verify -data "${DOCUMENT_SOURCE_PATH}" -in "${TS_CERT_PATH}" -CAfile "${TSA_CA_BUNDLE_PATH}" -untrusted "${TSA_CRT}" > /dev/null 2>&1; then
        echo "Verification successful!"
    else
        echo "Verification failed. Check your CA bundle or the TSA response."
    fi
fi

echo "Timestamping process complete."
exit 0
