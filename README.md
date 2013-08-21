DMSideMenuController
====================
What it does
------------
`DMSideMenuController` allows you to easily set up a menu underneath your main view that can be revealed by sliding the main view using a pan gesture ala Facebook iOS app and others.

How to use it
-------------
The interface is very simple. You set the main view controller and the menu view controller et voilà you're done. You can also configure the menu width, the amount of overlap, and whether gestures are enabled. And you can programatically set whether the menu is open or not (with optional animation).

To include it in your project, you can just take the `DMSideMenuController.h`/`DMSideMenuController.m` files and drop them into your project. Alternatively, you can embed this project as a subproject and add `$(CONFIGURATION_BUILD_DIR)` and `"$(BUILD_ROOT)/../IntermediateBuildFilesPath/UninstalledProducts"` to your `Header Search Paths` build setting.

License
-------
Licensed under the MIT license.