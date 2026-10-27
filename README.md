# Lucee Chart Extension

Docs: https://docs.lucee.org/reference/tags/chart.html

## Versioning and releases

Same scheme as the other Lucee extensions: `pom.xml` holds the next version as `X.Y.Z.N-SNAPSHOT`.

* **Every push** to `master` (or a version branch such as `2.0`, or `release/*`) builds, tests and publishes that `-SNAPSHOT` to the
  [Central snapshot repository](https://central.sonatype.com/repository/maven-snapshots/) and to S3. Afterwards the workflow
  commits `Set version to X.Y.Z.(N+1)-SNAPSHOT`, so every commit gets its own build number. The bump commit does not bump again.
* **Pull requests** and other branches only build and test, they never publish.
* **Manual run** (Actions > Run workflow), pick a type:
  * `release`: publishes `X.Y.Z.N` to Maven Central and S3, creates the GitHub release, then bumps to the next `-SNAPSHOT`.
  * `rc`, `beta`, `alpha`: publishes `X.Y.Z.N-RC` / `-BETA` / `-ALPHA` (signed) to S3 only, never to Central, creates a GitHub pre-release, then bumps.
  * `snapshot`: deploys the current `-SNAPSHOT` again, without a bump.
