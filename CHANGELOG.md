# Changelog

See [docs/RELEASE_NOTES.md](docs/RELEASE_NOTES.md) for the full release history.

## v0.1.6

- Confirmed all release-critical live-test patches are present in the store source.
- Confirmed builder/runtime support for sprite, beam, part beam, spiral ribbon, ribbon, mesh debris, texture decal, and light renderers.
- Fixed beam, part-beam, and light cleanup timing so `render.lifetime` is honored consistently.
- Kept decals texture-first by default; procedural and physical impact details remain explicit opt-ins.

