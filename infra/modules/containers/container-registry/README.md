# Azure Container Registry

Deploys an Azure Container Registry.

## Details

{{ Add detailed description for the module. }}

## Parameters

| Name                   | Type     | Required | Description                                                         |
| :--------------------- | :------: | :------: | :------------------------------------------------------------------ |
| `location`             | `string` | Yes      | The location to deploy to.                                          |
| `resourceTags`         | `object` | No       | Tags retrieved from parameter file.                                 |
| `acrName`              | `string` | Yes      | Provide a globally unique name for your Azure Container Registry    |
| `acrSku`               | `string` | Yes      | Provide a tier for your Azure Container Registry.                   |
| `adminUserEnabled`     | `bool`   | No       | Should the admin user be enabled (for non-managed identity access). |
| `anonymousPullEnabled` | `bool`   | Yes      | Allow anonymous pull (requires Premium SKU).                        |
| `managedIdentity`      | `string` | Yes      | Managed identity type for the registry.                             |
| `publicNetworkAccess`  | `string` | Yes      | Should the endpoint be publicly available?                          |

## Outputs

| Name          | Type     | Description                           |
| :------------ | :------: | :------------------------------------ |
| `id`          | `string` | The id of the container registry.     |
| `acrName`     | `string` | Generated name of container registry. |
| `loginServer` | `string` | Output the login server property.     |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```