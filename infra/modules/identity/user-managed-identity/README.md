# User Managed Identity

User Managed Identity

## Details

{{ Add detailed description for the module. }}

## Parameters

| Name           | Type     | Required | Description                         |
| :------------- | :------: | :------: | :---------------------------------- |
| `location`     | `string` | Yes      | Location                            |
| `resourceTags` | `object` | No       | Tags retrieved from parameter file. |
| `miname`       | `string` | Yes      | Name of managed identity.           |

## Outputs

| Name                       | Type     | Description                        |
| :------------------------- | :------: | :--------------------------------- |
| `managedIdentityPrincipal` | `string` | Principal of the managed identity. |
| `id`                       | `string` | ObjectId of the managed identity.  |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```