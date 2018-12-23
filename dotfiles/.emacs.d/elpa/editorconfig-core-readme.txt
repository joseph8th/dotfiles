This library is one implementation of EditorConfig Core, which parses
.editorconfig files and returns properties for given files.
This can be used in place of, for example, editorconfig-core-c.

This library is not an editor plugin and does not configure Emacs for editing
the files: this should be done with editorconfig-emacs.


Use from EditorConfig Emacs Plugin

editorconfig-emacs (v0.5 or later) can utilize this library.
Add following lines to your init.el:

    (setq editorconfig-get-properties-function
          'editorconfig-core-get-properties-hash)

This sexp configures editorconfig-emacs to call this library when getting
EditorConfig properties instead of the default function
editorconfig-get-properties-from-exec, which invokes external program
like editorconfig-core-c.


Functions

editorconfig-core-get-properties (&optional file confname confversion)

Get EditorConfig properties for FILE.

If FILE is not given, use currently visiting file.
Give CONFNAME for basename of config file other than .editorconfig.
If need to specify config format version, give CONFVERSION.

This functions returns alist of properties. Each element will look like
(KEY . VALUE) .


editorconfig-core-get-properties-hash (&optional file confname confversion)

Get EditorConfig properties for FILE.

This function is almost same as `editorconfig-core-get-properties', but
returns hash object instead.
