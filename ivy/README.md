## How to Build and Publish a Kythe Release

We build and publish our own Kythe releases, for several reasons:

- At the time of writing (September 2017), Kythe have not produced an "official" release in
  a long time. The last one was v0.0.26, in November 2016.  We often need to stay abreast of
  recent changes, especially those we contribute.
   
- Even when they do release, they don't publish those releases anywhere.

- Sometimes we need to make custom changes that may not (yet) be accepted into Kythe's master branch.


Here's how to build and publish a Kythe release. 
These instructions worked at Kythe commit [f1821c71459](https://github.com/google/kythe/commit/f1821c71459)

Note that we currently only care about the Java indexer jars provided by the release. Unfortunately
we have yet to find a way to create them without building the entire release, including the C++ 
and Go indexers.

### Build Release

1. Clone the Kythe repo, if you haven't before:
   ```bash
   cd ~/src
   git clone https://github.com/google/kythe.git 
   ```
   
   Or you may want to clone our fork, `https://github.com/benjyw/kythe.git`, if publishing custom changes.

1. Build the release:

   If you encounter build errors on MacOS, see the Prerequisites section below. 
   
   ```bash
   cd ~/src/kythe
   <sync to commit you want to build at>
   tools/modules/update.sh
   bazel build kythe/release
   ```
   
   This creates a tarball at `~/src/kythe/bazel-genfiles/kythe/release/kythe-v0.0.26.tar.gz`.

1. Generate custom version string:

   Our custom versions have the following format:
   
   `v{latest kythe release}.5-snowchain{incremented custom release}-{first 11 of kythe commit hash}`
   e.g. `kythe-v0.0.26.5-snowchain032-57c8dc79060`.
   
   Expand the release tarball into an appropriately-named directory under `~/kythe_releases/`:

   ```bash
   tar xfz bazel-genfiles/kythe/release/kythe-v0.0.26.tar.gz -C ~/kythe_releases/
   mv ~/kythe_releases/kythe-v0.0.26 ~/kythe_releases/kythe-v0.0.26.5-snowchain032-57c8dc79060
   ```

1. Test locally:

   If your repo is set up to consume a local release from `~/kythe_releases/`, as the Snowchain repo is 
   (see [`ivysettings.xml`](https://github.com/benjyw/snowchain/blob/master/build-support/ivy/ivysettings.xml))
   then you just need to update the relevant version strings. 
   
   E.g., in the Snowchain repo, update the version strings in 
   [`3rdparty/jvm/BUILD`](https://github.com/benjyw/snowchain/blob/master/3rdparty/jvm/BUILD) for the targets 
   `kythe-extractor` and `kythe-indexer`.

### Publish Release

You can publish your release with the following steps:
   
1. Clone the `binhost` repo, if you haven't before:
   ```bash
   cd ~/src
   git clone https://github.com/benjyw/binhost.git
   ```
   
1.  Run the publish script:
    ```bash
    cd ~/src/binhost
    git pull
    ./kythe/publish_kythe.sh v0.0.26.5-snowchain032-57c8dc79060
    ```
    
1.  Publish by pushing the resulting jars to master in this repo:
    ```bash
    git push origin master
    ```
    
1. Consume the published release

   Assuming your repo is set up to consume a binhost release, as the Snowchain repo is 
   (see [`ivysettings.xml`](https://github.com/benjyw/snowchain/blob/master/build-support/ivy/ivysettings.xml))
   then you just need to update the relevant version strings. 
   
   E.g., in the Snowchain repo, update the version strings in 
   [`3rdparty/jvm/BUILD`](https://github.com/benjyw/snowchain/blob/master/3rdparty/jvm/BUILD) for the targets 
   `kythe-extractor` and `kythe-indexer`.

### Prerequisites

If you're unable to build a release on MacOS, try these steps.

If you get an error about a `.h` file you probably need to update xcode's command line tools.

If none of these help, figure out what does and add it to this section.

1. Install/update tools
   1. Install/update Homebrew
      ```bash
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      ```

   1. Install/update Bazel

      `blob/master/WORKSPACE` in the kythe repo gives the range of bazel versions that are compatible with Kythe.
      If that's the version provided by homebrew you can simply install it with `brew install bazel`.

      Otherwise you can install other versions with:

      ```bash
      brew tap benjyw/bazel
      brew update
      brew install bazel@0.5.1
      brew link --overwrite --dry-run bazel@0.5.1
      brew unlink bazel
      brew link --overwrite bazel@0.5.1
      ```

      More detailed instructions are at https://github.com/benjyw/homebrew-bazel

   1. Install/update ossp-uuid
      ```bash
      brew install ossp-uuid
      ```

   1. Install/update md5sha1sum
      ```bash
      brew install md5sha1sum
      ```

1. Update xcode command line tools.
   ```bash
   xcode-select --install
   ```
