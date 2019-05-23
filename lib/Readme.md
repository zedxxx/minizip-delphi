Scripts to build `libminizip.dll` from [sources](https://github.com/nmoinvaz/minizip).

Step 1 - Prepare your environment (do it once):

* install [git for windows](https://git-scm.com/download/win)
* install [msys2](https://www.msys2.org/) and add its root directory to the PATH

Step 2 - Build library:

* run `get_src.cmd` to receive latest library version from GitHub
* run `build_32.cmd` / `build_64.cmd` to build 32/64 bit dll's