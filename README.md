# Spectra Core v2 Public

Sanitized public source release of the Spectra Core v2 contracts used by the
Spectra Diamond Router.

This release is derived from the private Core v2 source revision
`401bcc6847d9290b4f679caaa1413ff56219e16c`. It intentionally excludes private
Git history, deployment addresses, generated outputs, internal CI configuration,
and the Core v2 test suite. The deployment scripts retained here are required by
downstream router integration tests.

## Build

Install [Foundry](https://book.getfoundry.sh/getting-started/installation), then
run:

```sh
forge soldeer update
forge fmt --check
forge build
```

Production deployment scripts require explicit local JSON configuration. Global
organization deployment addresses are not included in this repository.

## License

The source is distributed under the repository's Business Source License 1.1.
See [LICENSE](./LICENSE) and [THIRD_PARTY_NOTICES.md](./THIRD_PARTY_NOTICES.md).
