# Contributing Guidelines

We'd love to accept your patches and contributions to this project. There are just a few small guidelines you need to follow.

## Sign off Your Work

The Developer Certificate of Origin (DCO) is a lightweight way for contributors to certify that they wrote or otherwise have the right to submit the code they are contributing to the project. Here is the full text of the [DCO](./DCO). Contributors must sign-off each commit by adding a Signed-off-by line to commit messages.

This is my commit message

```
Signed-off-by: Random J Developer <random@developer.example.org>
See git help commit:

-s, --signoff
    Add Signed-off-by line by the committer at the end of the commit log
    message. The meaning of a signoff depends on the project, but it typically
    certifies that committer has the rights to submit this work under the same
    license and agrees to a Developer Certificate of Origin (see
    http://developercertificate.org/ for more information).
```

# How to Contribute

With these steps you can make a contribution:

  1. Fork this repository, develop and test your changes on that fork.
  2. All commits have a meaningful description, are signed off as described above and verified.
  3. Submit a pull request from your fork to this project.

## Code reviews

All submissions, including submissions by project members, require review. We use GitHub pull requests for this purpose. Consult [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information on using pull requests. See the above stated requirements for PR on this project.

## Release Process

  1. Changes are automatically linted and tested using the [ct tool](https://github.com/helm/chart-testing) embedded as a GitHub action.
  2. Review is done manually by Bedag Informatik AG team members.
  3. Once review is done, the branch is merged into the master branch, where a Github action automatically creates a release on the GitHub repository. The new release is added to the index, laying in the gh-pages branch.

## Helm Docs

To have consistent README documentations for each chart we use the [helm-docs plugin](https://github.com/norwoodj/helm-docs). Make sure to write the chart README in a compatible format. Helm-Docs is executed on Push events.

**NOTE**: When creating your own `README.md.gotmpl`, don't forget to add it to your `.helmignore` file.

## Release Action

See which options are available on the [Github Release Action](https://github.com/buttahtoast/helm-release-action). We Use for publishing charts within this repository.

### Kube Linter

[Kube-Linter](https://github.com/stackrox/kube-linter) is supported for all charts and as global configuration. The Global configuration applies to all charts.

### Unit Tests

Unit Tests can be created on a chart basis. Unit Tests are optional.

## Technical Requirements

Your PR has to fulfill the following points, to be considered:

  * Chart should use [Bedag Manifests Library](./charts/manifests/README.md), if possible
  * Make use of [Artifacthub Annotations](https://github.com/artifacthub/hub/blob/master/docs/helm_annotations.md)
  * CI Jobs for linting must pass.
  * The title of the PR starts with the chart name (e.g. `[chart_name] Additional options for SecurityContext`)
  * Changes must follow [Helm best practices](https://helm.sh/docs/chart_best_practices/).
  * Changes to a chart require a version bump for that chart following [semver standard](https://semver.org/).
  * New/Changed Configurations for the chart are documented in it's `README.md` file.

### Versioning

Each chart's version follows the [semver standard](https://semver.org/). New charts should start at version `1.0.0`.

Any breaking changes to a chart (backwards incompatible) require:

  * Bump of the current Major version of the chart
  * State possible manual changes for this chart version in the `Upgrading` section of the chart's `README.md`

#### Immutability

Each release for each chart must be immutable. Any change to a chart (even just documentation) requires a version bump.

## Adding a new chart

Currently these are the only requirements to add a new chart:

  * **Only Helm Version 3+ Charts ([ApiVersion 2](https://helm.sh/docs/topics/v2_v3_migration/)) are accepted/supported.**
  * The chart has it's on `README.md` describing it's configuration options with default values. The documentation should also cover  some basic configuration examples.
  * Follow a best practice structure for the layout of the chart  directory (A good reference is [bitnami's blog](https://docs.bitnami.com/tutorials/production-ready-charts/) on this topic)
