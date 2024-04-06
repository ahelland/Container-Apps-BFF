# Private DNS Zone

A module for generating an empty Private DNS Zone.

## Details

{{Add detailed information about the module}}

## Parameters

| Name                  | Type            | Required | Description                                                                                         |
| :-------------------- | :-------------: | :------: | :-------------------------------------------------------------------------------------------------- |
| `resourceTags`        | `object`        | No       | Tags retrieved from parameter file.                                                                 |
| `zoneName`            | `string`        | Yes      | The name of the DNS zone to be created.  Must have at least 2 segments, e.g. hostname.org           |
| `registrationEnabled` | `bool`          | Yes      | Enable auto-registration for virtual network.                                                       |
| `vnetName`            | `null | string` | No       | The name of vnet to connect the zone to (for naming of link). Null if registrationEnabled is false. |
| `vnetId`              | `null | string` | No       | Vnet to link up with. Null if registrationEnabled is false.                                         |

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