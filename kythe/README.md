## How to Build and Publish a Kythe Release

We build and publish our own Kythe releases, for several reasons:

- Kythe don't release very often.  We often need to stay abreast of recent changes, 
  especially those we contribute.
   
- Even when they do release, they don't publish those releases anywhere.

- Sometimes we need to make custom changes that may not (yet) be accepted into Kythe's master branch.


Here's how to build and publish a Kythe release. 

Note that we publish a platform-specific release tarball, for consumption as binary utils, 
and also the platform-neutral .jar files, for separate consumption via JVM dependency resolution.


### Get Release From Docker Image

Our production build script generates a Dockerfile that builds a Kythe release, ensuring a stable, consistent environment.
It's often convenient to publish the artifacts from that release.

(Note: Production code can either consume the platform-specific Kythe binaries, published here, as binary utils, or
consume them from the Docker image. We should probably standardize on just one of those methods.)

Run [get_kythe_from_docker_image.sh](./get_kythe_from_docker_image.sh) from the root of this repo.
This will place a local release in `~/kythe_releases/`.

### Build Release Locally

Run [build_kythe.sh](./build_kythe.sh) from the root of this repo. 
This will build a local release and copy into `~/kythe_releases/`.

### Test Locally

Ensure your repo is set up to consume a local release from `~/kythe_releases/`, as the Toolchain repo is
(see [`ivysettings.xml`](https://github.com/benjyw/toolchain/blob/master/build-support/ivy/ivysettings.xml)).

Then update your version strings.  E.g., in the Toolchain repo, update the relevant version strings in
[`3rdparty/jvm/BUILD`](https://github.com/benjyw/toolchain/blob/master/3rdparty/jvm/BUILD) and in
[`src/python/toolchain/pants/kythe_release.py`](https://github.com/benjyw/toolchain/blob/master/src/python/toolchain/pants/kythe_release.py)

Now Pants will consume the local custom kythe release.

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
    ./kythe/publish_kythe.sh custom_kythe_version
    ```
    
1.  Publish by pushing the resulting files to master in this repo:
    ```bash
    git push origin master
    ```
    
1. Consume the published release

   Ensure your repo is set up to consume a binhost release, as the Toolchain repo is 
   (see [`ivysettings.xml`](https://github.com/benjyw/toolchain/blob/master/build-support/ivy/ivysettings.xml)).
   
   Then update your version strings, as described above for local testing.

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
