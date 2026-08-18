# lang-crk

## Installing `hfst-rs` to run scripts in Mac OS using `homebrew`

1. Make sure that the rust toolchain is installed:
   ```
   brew install rustup
   rustup toolchain install stable
   ```
2. Ensure that the rust toolchain is in your `$PATH` variable. if you are using `zsh`, the current default shell in Mac OS, add
   ```
   export PATH=$(brew --prefix rustup)/bin:$PATH
   ```
   to the `~/.zshrc` file.  **Make sure that you either also run this command in the current terminal or start a new terminal after you save the file**
3. Checkout the [hfst-rs](https://github.com/divvun/hfst-rs) repo.  Following similar giella conventions, these scripts expect the `hfst-rs` folder checked out at the samel level as `lang-crk` for this repo.  Note that some versions don't seem to pass all tests.  The `checkout` command gets a tagged commit that seemed to work on Aug 18 '26 (`df82593`).
   ```
   git clone https://github.com/divvun/hfst-rs.git
   git checkout dev-latest
   ```
4. Follow the instructions in the divvun repo to compile the rust tools, which are:
   ```
   cargo build
   cargo test
   ```

   Note that if the terminal complains that it cannot find `cargo` it's likely you forgot the step highlighted in bold in (2.)

5. You are ready to run the scripts. Just like the other scripts, you are expected to run them from the `lang-crk/fst/morphology` folder.
