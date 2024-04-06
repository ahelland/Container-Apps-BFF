# Private DNS A record

Creates an A record in a private DNS zone.

## Details

{{ Add detailed description for the module. }}

## Parameters

| Name         | Type     | Required | Description                                                                                |
| :----------- | :------: | :------: | :----------------------------------------------------------------------------------------- |
| `recordName` | `string` | Yes      | The name of the DNS record to be created.  The name is relative to the zone, not the FQDN. |
| `ipAddress`  | `string` | Yes      | IP address                                                                                 |
| `zone`       | `string` | Yes      | Name of DNS zone                                                                           |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```