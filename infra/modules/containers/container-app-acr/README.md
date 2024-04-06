# Container App ACR

Container App ACR

## Details

{{Add detailed information about the module}}

## Parameters

| Name                        | Type            | Required | Description                                                                                |
| :-------------------------- | :-------------: | :------: | :----------------------------------------------------------------------------------------- |
| `location`                  | `string`        | No       | Specifies the location for resources.                                                      |
| `resourceTags`              | `object`        | No       | Tags retrieved from parameter file.                                                        |
| `name`                      | `string`        | Yes      | Name of container app.                                                                     |
| `containerAppEnvironmentId` | `string`        | Yes      | The id of the container environment to deploy app to.                                      |
| `containerImage`            | `string`        | No       | Image of container. Defaults to mcr quickstart.                                            |
| `targetPort`                | `int`           | Yes      | The port exposed on the target container.                                                  |
| `transport`                 | `string`        | No       | Which transport protocol to expose.                                                        |
| `externalIngress`           | `bool`          | No       | Enable external ingress.                                                                   |
| `minReplicas`               | `int`           | No       | Minimum number of replicas.                                                                |
| `maxReplicas`               | `int`           | No       | Maximum number of replicas.                                                                |
| `containerName`             | `string`        | No       | Name of container.                                                                         |
| `containerRegistry`         | `string`        | Yes      | Registry to use for pulling images from. (Assumed to be in the form contosoacr.azurecr.io) |
| `identityName`              | `string`        | Yes      | Id of the user-assigned managed identity to use.                                           |
| `envVars`                   | `array`         | No       | Environment variables.                                                                     |
| `serviceId`                 | `null | string` | No       | Container App Service (Redis) to bind to.                                                  |

## Outputs

| Name          | Type     | Description                                                 |
| :------------ | :------: | :---------------------------------------------------------- |
| `name`        | `string` | Name of the container app.                                  |
| `principalId` | `string` | The principalId for the system managed identity of the app. |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```