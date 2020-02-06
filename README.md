# APITree: github-upload-api-actions

This [Github Action](https://github.com/actions) uploads and converts an [OpenAPI v2 / v3 specification](https://github.com/OAI/OpenAPI-Specification) into a technical API doc hosted on [APITree](https://www.apitree.com).

## Usage

Basic usage:
```
steps:
  - name: Checkout
    uses: actions/checkout@v2

  - name: Upload API
    uses: apitree/github-actions@master
    env:
      apitree_user_id: <APITREE_USER_ID>
      apitree_api_nickname: <APITREE_API_NICKNAME>
      apitree_api_file: openapi.yaml
      apitree_token: ${{ secrets.APITREE_TOKEN }}
```


Upload multiple APIs (e.g. internal and public API documentation):
```
steps:
  - name: Checkout
    uses: actions/checkout@v2

  - name: Upload internal API
    uses: apitree/github-actions@master
    env:
      apitree_user_id: <APITREE_USER_ID>
      apitree_api_nickname: <APITREE_API_NICKNAME_INTERNAL>
      apitree_api_file: openapi_internal.yaml
      apitree_api_type: private
      apitree_token: ${{ secrets.APITREE_TOKEN }}
  
  - name: Upload public API
    uses: apitree/github-actions@master
    env:
      apitree_user_id: <APITREE_USER_ID>
      apitree_api_nickname: <APITREE_API_NICKNAME_PUBLIC>
      apitree_api_file: openapi_public.yaml
      apitree_api_type: public
      apitree_token: ${{ secrets.APITREE_TOKEN }}
```

This action requires [actions/checkout@v2](https://github.com/actions/checkout) as a first step.

## Example Workflow

```
name: APITree

on:
  push:
    branches:
      - master

jobs:
  publish-api-doc:
    name: Publish API documentation on APITree
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Upload API
        uses: apitree/github-actions@master
        env:
          apitree_user_id: <APITREE_USER_ID>
          apitree_api_nickname: <APITREE_API_NICKNAME>
          apitree_api_file: openapi.yaml
          apitree_token: ${{ secrets.APITREE_TOKEN }}
```

It is recommended to create an [encrypted secret](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets) for the APITree API token (`apitree_token`).

## Inputs

The input parameters are mostly identical to the API endpoint `POST /api/{userId}/import`

* `apitree_user_id`: (**Required**) Your APITree ID which can be found under [hub.apitree.com/profile](https://hub.apitree.com/profile)

* `apitree_api_nickname`: (**Required**) The nickname is a shortname and will be used for the URL at which your API documentation can be accessed in APITree. Allowed characters: `A-Z, a-z, 0-9, -, _`

* `apitree_api_type`: (Optional) The visibility of the API. APIs of type `public` are visible for anyone in the APITree HUB. APIs of type `private` (default) are visible just for you (the members of the organization) and the people you share the API documentation with

* `apitree_auto_commit`: (Optional) Creates a new commit for the API specification file (default = `true`). Recommended to set to `false` on non-master branches.

* `apitree_commit_message`: (Optional) Commit message for the API specification file. Ignored if `apitree_auto_commit` is set to `false`. Max. 1000 characters, format: `[db70e4c](https://github.com/apitree/user-api/commit/db70e4c7757d13e518ccf5a923fa693d92aaa5eb) - Added new endpoints`

* `apitree_api_file`: (**Required**) Relative path to the API specification file - e.g. `spec/openapi.yaml`

* `apitree_token`: (**Required**) The API Token which is needed for authorization. Go to your APITree account and create an API Token with the scope `api`



## Feature requests and bug reports

Please file feature requests and bug reports as [github issues](https://github.com/apitree/github-actions/issues).

## License

See [LICENSE](LICENSE)