{ pkgs }:
  let
    scriptDirectory = name: scripts: with pkgs.lib;
      let
        fileAttrSet =
          mapAttrsRecursive
            (path: src: {
              name = last path;
              path = "$out/" + concatStringsSep "/" (init path);
              file = pkgs.writeScript (concatStringsSep "-" path) src;
            })
            scripts;
        files = collect (x: x ? file && isDerivation x.file) fileAttrSet;
        copier =
          concatMapStringsSep "\n"
            ({ name, path, file }: ''
              mkdir -p "${path}" && cp "${file}" "${path}"/"${name}"
            '')
            files;
      in
        pkgs.runCommand name
          { preferLocalBuild = true; }
          copier;

  in  { port, scripts, user }:
    let
      conf = pkgs.writeText "cgi-mighty-conf" ''
        Port: ${toString port}
        Host: 127.0.0.1
        Pid_File: /var/run/mighty-${toString port}.pid
        Logging: No
      '';
      routes = pkgs.writeText "cgi-mighty-routes" ''
        [*]
        / => ${scriptDirectory "cgi" scripts}
      '';
    in {
      wantedBy = ["multi-user.target"];
      environment = { PORT = builtins.toString port; };
      serviceConfig = {
        User = user;
        ExecStart = "${pkgs.haskellPackages.mighttpd2}/bin/mighty ${conf} ${routes}";
      };
    }
