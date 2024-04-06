# Container App Environment

Deploys a Container Environment in Azure.

## Details

{{Add detailed information about the module}}

## Parameters

| Name              | Type     | Required | Description                                                                                                                      |
| :---------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------- |
| `environmentName` | `string` | Yes      | Name of Container Environment                                                                                                    |
| `location`        | `string` | Yes      | Location for Container Environment                                                                                               |
| `resourceTags`    | `object` | No       | Tags retrieved from parameter file.                                                                                              |
| `vnetInternal`    | `bool`   | No       | Should the Container Environment be connected to a custom virtual network? Enabling this also requires a valid value for snetId. |
| `snetId`          | `string` | Yes      | If vnet integration is enabled which subnet should the container environment be connected to?                                    |

## Outputs

| Name            | Type     | Description                        |
| :-------------- | :------: | :--------------------------------- |
| `defaultDomain` | `string` | The default domain of the cluster. |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```