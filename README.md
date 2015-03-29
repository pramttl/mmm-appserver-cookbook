# create-cookbook

Makemymails App Server cookbook.

## Supported Platforms

Ubuntu 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['create']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### create::default

Include `create` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[create::default]"
  ]
}
```

## License and Authors

Author:: Pranjal Mittal (mittal.pranjal@gmail.com)
