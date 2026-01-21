#!/bin/bash
set -e

#################################################
# CONFIGURATION (UPDATE THESE)
#################################################

# Initial domain name (WITHOUT .onmicrosoft.com)
INITIAL_DOMAIN=""

# Tenant Object ID
TENANT_ID=""

# Output directory
OUTPUT_DIR="${INITIAL_DOMAIN}-b2c-policies"

# PH_SUSI settings
LOGIN_PAGE_URL=""
# skip phone verification for testing
PHONE_NUMBER=""

# App registrations
PROXY_IDEF_CLIENT_ID=""
IDEF_CLIENT_ID=""

# B2C Extensions App
B2C_EXT_APP_OBJECT_ID=""
B2C_EXT_APP_CLIENT_ID=""

#################################################
# SOURCE FILES
#################################################

SOURCE_FILES=(
  initaldomainname.onmicrosoft.com-B2C_1A_PASSWORDRESET.xml
  initaldomainname.onmicrosoft.com-B2C_1A_PH_SUSI.xml
  initaldomainname.onmicrosoft.com-B2C_1A_PH_TRUSTFRAMEWORKLOCALIZATION.xml
  initaldomainname.onmicrosoft.com-B2C_1A_PROFILEEDIT.xml
  initaldomainname.onmicrosoft.com-B2C_1A_SIGNUP_SIGNIN.xml
  initaldomainname.onmicrosoft.com-B2C_1A_TRUSTFRAMEWORKBASE.xml
  initaldomainname.onmicrosoft.com-B2C_1A_TRUSTFRAMEWORKEXTENSIONS.xml
  initaldomainname.onmicrosoft.com-B2C_1A_TRUSTFRAMEWORKLOCALIZATION.xml
)

#################################################
# CREATE OUTPUT DIRECTORY
#################################################

mkdir -p "$OUTPUT_DIR"

#################################################
# COPY + RENAME FILES
#################################################

for FILE in "${SOURCE_FILES[@]}"; do
  NEW_NAME="${FILE/initaldomainname.onmicrosoft.com/${INITIAL_DOMAIN}.onmicrosoft.com}"
  cp "$FILE" "$OUTPUT_DIR/$NEW_NAME"
done

#################################################
# GLOBAL PLACEHOLDER REPLACEMENT
#################################################

for FILE in "$OUTPUT_DIR"/*.xml; do
    sed -i.bak \
    -e "s|\${initaldomainname}|${INITIAL_DOMAIN}|g" \
    -e "s|\${tenant_id}|${TENANT_ID}|g" \
    "$FILE"
    rm "$FILE.bak"
done

#################################################
# PH_SUSI FIXES
#################################################

PH_SUSI_FILE="$OUTPUT_DIR/${INITIAL_DOMAIN}.onmicrosoft.com-B2C_1A_PH_SUSI.xml"

sed -i.bak \
  -e "/<ContentDefinition Id=\"api.signuporsignin\">/,/<\/ContentDefinition>/ s|<LoadUri>.*</LoadUri>|<LoadUri>${LOGIN_PAGE_URL}</LoadUri>|" \
  -e "/<ContentDefinition Id=\"api.phonefactor\">/,/<\/ContentDefinition>/ s|<LoadUri>.*</LoadUri>|<LoadUri>${LOGIN_PAGE_URL}</LoadUri>|" \
  -e "/<ContentDefinition Id=\"api.selfasserted\">/,/<\/ContentDefinition>/ s|<LoadUri>.*</LoadUri>|<LoadUri>${LOGIN_PAGE_URL}</LoadUri>|" \
  -e "/<ContentDefinition Id=\"api.selfasserted.profileupdate\">/,/<\/ContentDefinition>/ s|<LoadUri>.*</LoadUri>|<LoadUri>${LOGIN_PAGE_URL}</LoadUri>|" \
  -e "/<ContentDefinition Id=\"api.localaccountsignup\">/,/<\/ContentDefinition>/ s|<LoadUri>.*</LoadUri>|<LoadUri>${LOGIN_PAGE_URL}</LoadUri>|" \
  -e "/<ContentDefinition Id=\"api.localaccountsignin\">/,/<\/ContentDefinition>/ s|<LoadUri>.*</LoadUri>|<LoadUri>${LOGIN_PAGE_URL}</LoadUri>|" \
  -e "/<ContentDefinition Id=\"api.localaccountpasswordreset\">/,/<\/ContentDefinition>/ s|<LoadUri>.*</LoadUri>|<LoadUri>${LOGIN_PAGE_URL}</LoadUri>|" \
  -e "/<ContentDefinition Id=\"api.socialccountsignup\">/,/<\/ContentDefinition>/ s|<LoadUri>.*</LoadUri>|<LoadUri>${LOGIN_PAGE_URL}</LoadUri>|" \
  -e "s|\${phonenumber}|${PHONE_NUMBER}|g" \
  "$PH_SUSI_FILE"

rm "$PH_SUSI_FILE.bak"

#################################################
# TRUSTFRAMEWORKEXTENSIONS FIXES
#################################################

TFE_FILE="$OUTPUT_DIR/${INITIAL_DOMAIN}.onmicrosoft.com-B2C_1A_TRUSTFRAMEWORKEXTENSIONS.xml"

sed -i.bak \
  -e "s|<b2c-extensions-app Object ID>|${B2C_EXT_APP_OBJECT_ID}|g" \
  -e "s|<b2c-extensions-app Application (client) ID>|${B2C_EXT_APP_CLIENT_ID}|g" \
  -e "s|\${ProxyIdentityExperienceFramework Application (client) ID}|${PROXY_IDEF_CLIENT_ID}|g" \
  -e "s|\${IdentityExperienceFramework Application (client) ID}|${IDEF_CLIENT_ID}|g" \
  "$TFE_FILE"

rm "$TFE_FILE.bak"

#################################################
# SAFETY CHECKS (FAIL FAST)
#################################################

if grep -R "\${initaldomainname}" "$OUTPUT_DIR"; then
  echo "❌ ERROR: initaldomainname placeholder still present"
  exit 1
fi

if grep -R "b2c-extensions-app" "$OUTPUT_DIR"; then
  echo "❌ ERROR: B2C extensions placeholders still present"
  exit 1
fi

#################################################
# DONE
#################################################

echo "✅ B2C policy setup completed successfully!"
echo "📂 Output directory: $OUTPUT_DIR"
