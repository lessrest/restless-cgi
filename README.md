# Restless CGI configuration for Nix

This is a Nix function that makes a systemd service definition for a
CGI web server that serves a simple directory of CGI scripts, which
you can define inline in your Nix configuration.

Here's an example from a `configuration.nix`:

    systemd.services.cgi-example =
      (import (pkgs.fetchFromGitHub {
        owner = "lessrest";
        repo = "restless-cgi";
        rev = "bf95bccc2ce65bcda1b91a149a2764d97b185319";
        sha256 = "0kfkcdskij3ngv43ajlhwm31yqy3a3mbnx9kbdjaqhp0179cjx8j";
      }) { inherit pkgs; }) {
        port = 1988;
        user = "someone";
        scripts = {
          foo = ''
            #!${pkgs.bash}/bin/bash
            printf "Content-Type: text/plain\n"
            printf "\r\n"
            echo wow, foo
          '';
          bar = ''
            #!${pkgs.bash}/bin/bash
            printf "Content-Type: text/plain\n"
            printf "\r\n"
            echo wow, bar
          '';
        };
      };

This refers to the previous commit, since I'm not
[Quine](https://en.wikipedia.org/wiki/Quine_\(computing\)) enough to
get the hash of the current commit into the source code of the
current commit.

(The user chosen must be able to write to `/tmp`, so don't use
`nobody`.)

The configuration uses Kazu Yamamoto's nice
[Mighttpd2](http://mew.org/~kazu/proj/mighttpd/en/) CGI server,
written in Haskell and based on the Warp HTTP server (which is fast
and robust).
