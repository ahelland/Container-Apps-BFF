# Private Endpoint

Private Endpoint

## Details

{{Add detailed information about the module}}

## Parameters

| Name                        | Type            | Required | Description                                     |
| :-------------------------- | :-------------: | :------: | :---------------------------------------------- |
| `location`                  | `string`        | No       | Specifies the location for resources.           |
| `resourceTags`              | `object`        | No       | Tags retrieved from parameter file.             |
| `peName`                    | `string`        | Yes      | Name of the Private Endpoint.                   |
| `serviceConnectionGroupIds` | `string`        | Yes      | String array - "foo, bar"                       |
| `snetId`                    | `null | string` | No       | Subnet to attach private endpoint to.           |
| `serviceConnectionId`       | `string`        | Yes      | The connection id for the private link service. |

## Outputs

| Name   | Type     | Description                            |
| :----- | :------: | :------------------------------------- |
| `ip`   | `string` | IP Address of Private Endpoint         |
| `fqdn` | `string` | FQDN (public zone) of Private Endpoint |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```