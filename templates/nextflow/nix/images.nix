# TODO: With docker image & apptainer image
{
  perSystem = _: {
    packages.image = {
      name = "capture-selex-workflow";
      tag = "latest";

      config = {
        Cmd = ["/bin/bash"];
        Env = [
          "PATH=/bin"
          "LANG=C.UTF-8"
        ];
      };

      maxLayers = 100;
    };
  };
}
