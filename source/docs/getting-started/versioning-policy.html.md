---
guide: Getting Started
section: Versioning Policy
menu: getting-started
---

Lita follows [Semantic Versioning](http://semver.org). Lita's version number has three parts: MAJOR, MINOR, and PATCH, e.g. 1.2.3. In short:

* Any changes which could cause existing plugins to raise exceptions or change behavior will increase the MAJOR version.
* Any new functionality that is completely backwards-compatible will increase the MINOR version.
* Any bug fixes or changes to minor behavior that were not working as documented will increase the PATCH version.

### Deprecation policy {#deprecation-policy}

A deprecated feature is one that is marked to be removed in a future version. It may or may not have replacement or alternative functionality.

Rules about deprecations:

* Features will only be deprecated in new MAJOR versions. This means that all non-deprecated features will continue to work in the next MAJOR version.
* When a feature is deprecated, it will not be completely removed until the following MAJOR version. This means that upgrading Lita to a new MAJOR version will only potentially break plugins using deprecated functionality from two MAJOR versions ago. A full MAJOR version period is given for plugins to safely update code for any deprecated functionality.
