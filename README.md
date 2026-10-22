# OversizeAppStoreServices

Pass credentials to the authenticator. The package does not read Keychain or select an account.

```swift
let authenticator = CredentialsAuthenticator(credentials: credentials)
let service = AppsService(authenticator: authenticator, cacheAccountID: accountID.uuidString)
```

Services capture credentials at initialization. Recreate services and their consumers after changing accounts or replacing keys. Pass `cacheAccountID` explicitly to isolate cached responses and derived values; without it caching is disabled.

Factory users register `Container.shared.appStoreConfiguration` with a `Result<ASCAccountConfiguration, Error>`. The default fails with `ASCAuthenticationError.missingCredentials` before sending a request. Restore the registration after resetting Factory registrations.

AppConnector stores credentials in `OversizeAppStoreKit.AccountCredentialsStore`, using `OversizeServices.Keychain`. Existing UUID keys and the JSON format are preserved.
