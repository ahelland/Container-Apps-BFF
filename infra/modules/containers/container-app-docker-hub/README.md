# Container App Docker Hub

Container App Docker Hub

## Details

{{Add detailed information about the module}}

## Parameters

| Name                        | Type         | Required | Description                                           |
| :-------------------------- | :----------: | :------: | :---------------------------------------------------- |
| `location`                  | `string`     | No       | Specifies the location for resources.                 |
| `resourceTags`              | `object`     | No       | Tags retrieved from parameter file.                   |
| `name`                      | `string`     | Yes      | Name of container app.                                |
| `containerAppEnvironmentId` | `string`     | Yes      | The id of the container environment to deploy app to. |
| `containerImage`            | `string`     | No       | Image of container. Defaults to mcr quickstart.       |
| `containerName`             | `string`     | Yes      | Name of container.                                    |
| `targetPort`                | `int`        | Yes      | The port exposed on the target container.             |
| `exposedPort`               | `int | null` | No       | The port exposed on ingress.                          |
| `transport`                 | `string`     | No       | Which transport protocol to expose.                   |
| `minReplicas`               | `int`        | No       | Minimum number of replicas.                           |
| `maxReplicas`               | `int`        | No       | Maximum number of replicas.                           |
| `envVars`                   | `array`      | No       | Environment variables.                                |

## Outputs

| Name   | Type     | Description                |
| :----- | :------: | :------------------------- |
| `name` | `string` | Name of the container app. |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```