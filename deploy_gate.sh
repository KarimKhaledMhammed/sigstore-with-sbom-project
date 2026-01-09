#!/bin/bash

IMAGE=$1
EMAIL="karimkhaledmohammed@gmail.com" # replace this with your email
ISSUER="https://github.com/login/oauth" # or https://accounts.google.com

echo "🔒 INSPECTING ARTIFACT: $IMAGE"

# 1. Verify the attestation exists and is signed by the trusted email
# We use jq to extract the specific 'status' field from the predicate 
OUTPUT=$(cosign verify-attestation \
    --certificate-identity=$EMAIL \
    --certificate-oidc-issuer=$ISSUER \
    --type custom \
    $IMAGE 2>/dev/null | jq -r '.payload | @base64d | fromjson | .predicate.Data | fromjson | .status')

# 2. The Policy Logic
if [[ "$OUTPUT" == "approved" ]]; then
    echo "✅ POLICY PASSED: Image is attested as 'approved' by $EMAIL."
    echo "🚀 STARTING CONTAINER..."
    podman run --rm $IMAGE
else
    echo "❌ POLICY FAILED: Image is missing valid attestation or is not approved."
    echo "Reason: Status found was '$OUTPUT'"
    exit 1
fi