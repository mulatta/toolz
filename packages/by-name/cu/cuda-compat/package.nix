{
  runCommand,
  cudaPackages_12,
}:
# CUDA compatibility wrapper for PyPI wheels
# Provides standard .so symlinks to Nix CUDA .alt.so libraries
# This allows PyPI wheels (cupy, numba) to find CUDA libraries via dlopen()
runCommand "cuda-compat" { } ''
    mkdir -p $out/lib

    # NVIDIA Runtime Compilation (nvrtc)
    ln -s ${cudaPackages_12.cuda_nvrtc.lib}/lib/libnvrtc.alt.so $out/lib/libnvrtc.so
    ln -s ${cudaPackages_12.cuda_nvrtc.lib}/lib/libnvrtc.alt.so.12 $out/lib/libnvrtc.so.12
    ln -s ${cudaPackages_12.cuda_nvrtc.lib}/lib/libnvrtc.alt.so.12.8.93 $out/lib/libnvrtc.so.12.8.93

    ln -s ${cudaPackages_12.cuda_nvrtc.lib}/lib/libnvrtc-builtins.alt.so $out/lib/libnvrtc-builtins.so
    ln -s ${cudaPackages_12.cuda_nvrtc.lib}/lib/libnvrtc-builtins.alt.so.12.8 $out/lib/libnvrtc-builtins.so.12.8
    ln -s ${cudaPackages_12.cuda_nvrtc.lib}/lib/libnvrtc-builtins.alt.so.12.8.93 $out/lib/libnvrtc-builtins.so.12.8.93

    # NVIDIA JIT Linker (nvJitLink)
    ln -s ${cudaPackages_12.libnvjitlink.lib}/lib/libnvJitLink.alt.so $out/lib/libnvJitLink.so
    ln -s ${cudaPackages_12.libnvjitlink.lib}/lib/libnvJitLink.alt.so.12 $out/lib/libnvJitLink.so.12
    ln -s ${cudaPackages_12.libnvjitlink.lib}/lib/libnvJitLink.alt.so.12.8.93 $out/lib/libnvJitLink.so.12.8.93

    # CUDA Runtime (cudart)
    ln -s ${cudaPackages_12.cuda_cudart.lib}/lib/libcudart.alt.so $out/lib/libcudart.so
    ln -s ${cudaPackages_12.cuda_cudart.lib}/lib/libcudart.alt.so.12 $out/lib/libcudart.so.12
    ln -s ${cudaPackages_12.cuda_cudart.lib}/lib/libcudart.alt.so.12.8.90 $out/lib/libcudart.so.12.8.90

    # Create a setup hook for users
    mkdir -p $out/nix-support
    cat > $out/nix-support/setup-hook <<EOF
  # Add CUDA compat symlinks AND original .alt.so libraries to LD_LIBRARY_PATH
  # Python packages (cupy, numba) use dlopen() to find standard .so names
  # BUT nvrtc itself looks for .alt.so builtins internally
  export LD_LIBRARY_PATH=$out/lib:${cudaPackages_12.cuda_nvrtc.lib}/lib:${cudaPackages_12.libnvjitlink.lib}/lib:${cudaPackages_12.cuda_cudart.lib}/lib\''${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}

  # Set CUDA_PATH for cupy JIT compilation (needs CUDA headers)
  export CUDA_PATH=${cudaPackages_12.cudatoolkit}
  export CUDA_HOME=\$CUDA_PATH
  EOF
''
// {
  meta = {
    description = "CUDA compatibility wrapper providing standard .so symlinks for PyPI wheels";
    longDescription = ''
      Nix CUDA packages use .alt.so naming to avoid conflicts with system CUDA.
      This package provides standard .so symlinks that PyPI wheels (cupy, numba)
      expect when using dlopen() to load CUDA libraries dynamically.
    '';
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
