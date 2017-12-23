# Duplicacy Sandbox

The `Makefile` in this directory builds and maintains a very basic
Duplicacy setup for experimentation.  The area to be backed up is
initialized in the `root` subdirectory and contains a `.duplicacy`
directory which may be customized.  Backups are stored in the
`storage` directory.

To build, do a `make` or a `make populate` (see descriptions below).

By default, the sandbox assumes that Duplicacy is available in the
current `$PATH`, but this can be overidden by setting an explicit path
setting the `DUPLICACY` variable.

Useful targets:

 * `build` (The default) - Builds and initializes an empty sandbox.
 * `populate` - Creates five files in the root, revises each five
    times and creates a backup of all five after each revision
 * `clean` - Removes everything.
 * `backup` - Runs a backup of the root
 * `list` - Lists all revisions
 * `files` - Lists all revisions and files
 * `prune` - Does an exhaustive prune
