# Contributing Guidelines

We'd love to accept your patches and contributions to this project. There are just a few small guidelines you need to follow.

# How to Contribute

With these steps you can make a contribution:

  1. Fork this repository, develop and test your changes on that fork
  2. Commit changes
  3. Submit a [pull request](#pull-requests) from your fork to this project.

Before starting, go through the requirements below.  

## Commits

Please have meaningful commit messages.

### Commit Signature Verification

Each commit's signature must be verified.

  * [About commit signature verification](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/about-commit-signature-verification)

### Sign off Your Work

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

# Pull Requests

All submissions, including submissions by project members, require review. We use GitHub pull requests for this purpose. Consult [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information on using pull requests. See the above stated requirements for PR on this project.

Your Pull Request has to fulfill the following points, to be considered:

  * Workflows must pass.
  * DCO Check must pass.
  * All commits correspond to the requirements (See [Commits](#commits))
  * The title of the PR starts with the chart name (e.g. `[chart_name] Additional options for SecurityContext`)
  * Changes to a chart require a version bump for that chart following [versioning conventions](#versioning).
  * New/Changed Configurations for the chart are documented in it's `README.md.gotmpl` file.

## Versioning

Each chart's version follows the [semver standard](https://semver.org/). New charts should start at version `1.0.0`, if it's considered stable. If it's not considered stable, it must be released as [prerelease](#prerelease).

Any breaking changes to a chart (backwards incompatible) require:

  * Bump of the current Major version of the chart
  * State possible manual changes for this chart version in the `Upgrading` section of the chart's `README.md.gotmpl` ([See Upgrade](#upgrades))

### Immutability

Each release for each chart must be immutable. Any change to a chart (even just documentation) requires a version bump. Trying to release the same version twice will result in an error.

## Work in Progress

By adding `WIP: *` as prefix for your pull request title, your pull request is considered not yet ready for review. This changes when removing this prefix later.

## Review

When creating a Pull Request is automatically assigned. If your Pull Request does not have any activity after certain days, feel free to comment a reminder (it might happen that we forget about it, since we maintain this repository part time). Your Pull Request requires approve to be mergeable.

# Chart Requirements

There are certain requirements charts have to match, to be maintained in your Helm Repository. Most of the requirements are relevant when you are planning to add a new chart to the repository.

## Manifests Library

**Important**: All of the maintained charts in this repository should make use of the [Bedag Manifests Library](./charts/manifests). There might be exceptions.

When adding the Bedag Manifests Library as dependency, we don't add it as local dependency (aka via `file://..`) since the library itself has dependencies, which are not included that way. Therefor you must declare the dependency from the repository itself:

```
dependencies:
  - name: manifests
    version: "~0.4.0"
    repository: https://bedag.github.io/helm-charts/
```

## Documentation

The documentation for each chart is done with [helm-docs](https://github.com/norwoodj/helm-docs). This way we can ensure that values are consistent with the chart documentation.

**NOTE**: When creating your own `README.md.gotmpl`, don't forget to add it to your `.helmignore` file.

### Major Changes

Your chart should have a dedicated documentation part, where major changes to the chart are mentioned which cause a new major release. Here's a little example on how you could do that:

```
# Major Changes

Major Changes are documented with the version affected. **Before upgrading to a new version, check this section out!**

| **Chart Version** | **Change/Description** | **Commits/PRs** |
| :---------------- | :--------------------- | :-------------- |
||||
```

### Upgrades

If your chart requires manual interaction for version upgrades (might be the case for major upgrades) you need to mention the exact instructions in a dedicated documentation part of your chart. That's not the case for upgrades, where no specific interaction is required.

## Maintainer

Charts published by Bedag will only have Bedag as maintainer and no dedicated contributors.

```
maintainers:
- name: Bedag
  email: sre@bedag.ch
```

## Dependencies

Dependency versions should be set to a fixed version. We allow version fixing over all bugfix versions (eg. `~1.0.0`), since bugfix releases should not have big impact.

```
dependencies:
- name: "apache"
  version: "~1.3.0"
  repository: "https://charts.bitnami.com/bitnami"
```

There might be cases where this rule can not be applied, we are open to discuss that.


## ArtifactHub Annotations

Since we release our charts on [Artifacthub](https://artifacthub.io/) we encourage making use of the provided chart annotations for Artifacthub.

  * [All Artifacthub Annotations](https://github.com/artifacthub/hub/blob/master/docs/helm_annotations.md)

In some cases they might not be required.

### Prerelease

Annotation to mark chart release as prerelease:

```
annotations:
  artifacthub.io/prerelease: "true"
```

### SecurityUpdates

Annotation to mark that chart release contains security updates:

```
annotations:
  artifacthub.io/containsSecurityUpdates: "true"
```

### Changelog

Changes on a chart must be documented in a chart specific changelog. For every new release the entire artifacthub.io/changes needs to be rewritten. Each change requires a new bullet point following the pattern **[{type}]**: {description}. Please use the following template:


```
artifacthub.io/changes: |
  - "[Added]: Something New was added"
  - "[Changed]: Changed Something within this chart"
  - "[Changed]: Changed Something else within this chart"
  - "[Deprecated]: Something deprecated"
  - "[Removed]: Something was removed"
  - "[Fixed]: Something was fixed"
  - "[Security]: Some Security Patch was included"
```

# Workflows

The following Workflows are executed on named events.

## Push

On each Push [Helm-Docs](#documentation) will executed (fails on protected branches).

## Pull Requests

On creating a Pull Request the following workflows will be executed:

  1. Chart Linting - All Charts are linted using the [ct tool](https://github.com/helm/chart-testing).
  2. Chart Installation - All Charts are installed to KinD instance using the [ct tool](https://github.com/helm/chart-testing).
  3. Chart Release Dry-Run - Only charts which had changes to their **Chart.yaml** file are considered for the Release Dry-Run. No Release will be made during Dry-Run. The following checks must pass:
    * Passed [Kube-Linter](https://github.com/stackrox/kube-linter) Tests (Required).
    * Passed [Helm Unit-Tests](https://github.com/quintush/helm-unittest) if any are defined (Optional).

  See which options are available on the [Github Release Action](https://github.com/buttahtoast/helm-release-action), which is used for releases.  

## Release (Master Push)

On making a push on master the following workflows will be executed:

  1. Chart Release - Only charts which had changes to their **Chart.yaml** file are considered for the Release.

See which options are available on the [Github Release Action](https://github.com/buttahtoast/helm-release-action), which is used for releases.
