# Azure AD B2C – Phone-based Sign Up & Sign In (Custom Policy)

## Prerequisites
- An active Azure Active Directory B2C tenant
- Initial domain name (example: `xxxxx.onmicrosoft.com`)
- Tenant ID
- Access to Azure Portal

---

## Step 1: Generate Policy Keys

Navigate to:

**Azure AD B2C → Identity Experience Framework → Policy Keys**

Create the following keys:

| Name                         | Key Type | Key Usage   |
|------------------------------|----------|-------------|
| TokenSigningKeyContainer     | RSA      | Signature   |
| TokenEncryptionKeyContainer  | RSA      | Encryption  |
| FacebookSecret               | RSA      | Signature   |

---

## Step 2: Create App Registrations

### 1. IdentityExperienceFramework Application

- **Account type**: Accounts in this organizational directory only (Single tenant)
- **Redirect URI**
  - Web:
    ```
    https://login.microsoftonline.com/<initialdomainname>.onmicrosoft.com
    ```

#### Authentication
- Enable **ID tokens**

#### API Permissions
- Microsoft Graph (Delegated):
  - `openid`
  - `offline_access`

#### Expose an API
- Add **Application ID URI**
- Add a scope:
  - Name: `user_impersonation`

---

### 2. ProxyIdentityExperienceFramework Application

- **Account type**: Accounts in this organizational directory only (Single tenant)

#### Redirect URIs
- Web:
  ```
  https://jwt.ms
  ```
- Mobile and desktop applications:
  ```
  https://login.microsoftonline.com/<initialdomainname>.onmicrosoft.com
  ```

#### Authentication
- Enable **ID tokens**
- Enable **Public client flows**

#### API Permissions
- Microsoft Graph (Delegated):
  - `openid`
  - `offline_access`
- Azure Active Directory Graph (Delegated):
  - `User.Read`
- APIs my organization uses:
  - `IdentityExperienceFramework`
    - `user_impersonation`

---

## Step 3: Download and Prepare Custom Policy Files

Download policy files from GitHub:

https://github.com/sivakumaru2002/Adb2c-ph-susi

Upload location in Azure:
```
Azure AD B2C → Identity Experience Framework → Custom Policies
```

---

### File Renaming

Replace `initialdomainname.onmicrosoft.com` with your **actual initial domain name** in **all files**.

---

### Placeholder Replacement

Replace in all files:

- `${initialdomainname}` → Your initial domain
- `${tenant_id}` → Your Tenant ID

---

### PH_SUSI Configuration

Replace the login page URL with your hosted `selfAsserted.html`.
Replace `${phonenumber}` with any number to skip OTP.

---

### TRUSTFRAMEWORKEXTENSIONS Configuration

Replace all Application (Client) IDs with real values for:
- IdentityExperienceFramework
- ProxyIdentityExperienceFramework

---

## Step 4: Upload Order

1. B2C_1A_TRUSTFRAMEWORKBASE.xml
2. B2C_1A_TRUSTFRAMEWORKLOCALIZATION.xml
3. B2C_1A_PH_TRUSTFRAMEWORKLOCALIZATION.xml
4. B2C_1A_TRUSTFRAMEWORKEXTENSIONS.xml
5. B2C_1A_SIGNUP_SIGNIN.xml
6. B2C_1A_PH_SUSI.xml
7. B2C_1A_PROFILEEDIT.xml
8. B2C_1A_PASSWORDRESET.xml

---

## Deployment Complete

Custom policies are successfully deployed.

---

## Testing

Create a multitenant app registration (Org + Personal Microsoft accounts) and test the policy.

---

