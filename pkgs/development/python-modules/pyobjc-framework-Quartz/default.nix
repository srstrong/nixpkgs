{ stdenv, buildPythonPackage, pythonOlder, fetchPypi, darwin, python,
pyobjc-core, pyobjc-framework-Cocoa }:

buildPythonPackage rec {
  pname = "pyobjc-framework-Quartz";
  version = "6.2.2";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1nkwi4g7vs26m94qgvn1n1vz214yfhzcgqq47zrylqch530cymjs";
  };

  postPatch = ''
    # Hard code correct SDK version
    substituteInPlace pyobjc_setup.py \
      --replace 'os.path.basename(data)[6:-4]' '"${darwin.apple_sdk.sdk.version}"'
  '';

  buildInputs = with darwin.apple_sdk.frameworks; [
    AppKit
    CoreVideo
    Foundation
    Quartz
  ];

  propagatedBuildInputs = [
    pyobjc-core
    pyobjc-framework-Cocoa
  ];

  # clang-7: error: argument unused during compilation: '-fno-strict-overflow'
  hardeningDisable = [ "strictoverflow" ];

  dontUseSetuptoolsCheck = true;
  pythonImportsCheck = [ "Quartz" ];

  meta = with stdenv.lib; {
    description = "Wrappers for the framework Quartz on Mac OS X";
    homepage = "https://pythonhosted.org/pyobjc-framework-Quartz/";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
