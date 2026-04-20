# Branching Conventions

## Integration Branch

- **`master`** — the single integration branch. All features and fixes merge here.

There is no `develop`, `main`, or `staging` branch. Git history shows `origin/master` as the sole remote branch tracked.

## Feature / Fix Branch Naming

From pull request merge commits in the git log:

```
arabold/dependabot/npm_and_yarn/lodash-4.17.21
arabold/dependabot/npm_and_yarn/y18n-4.0.1
```

Pattern observed: `{author}/{tool}/{area}/{package}-{version}` for Dependabot. Human feature branches follow no strict convention (small repo, mostly maintained by one author).

## Release Tagging

No `git tag` history visible in the remote. Releases are tracked as plain version-bump commits directly on `master`:

```
c4b35df 2.5.2
0a11d31 2.5.1
f7c6d1b 2.5.0
2dd71fe 2.4.0
8897e77 2.3.0
566ef00 2.2.0
335c260 2.1.0
6d0347c 2.0.1
f01aaa5 2.0.0
```

The `postversion` npm script pushes tags automatically: `git push && git push --tags`.

## Pull Request Workflow

Merge commits follow the format:
```
Merge pull request #34 from arabold/dependabot/npm_and_yarn/lodash-4.17.21
```

Standard GitHub merge commit style. No squash enforcement observed.

## Summary

| Aspect | Convention |
|--------|-----------|
| Integration branch | `master` |
| Feature branches | no strict format |
| Release tracking | version-bump commits + npm version tags |
| Merges | GitHub merge commits |
