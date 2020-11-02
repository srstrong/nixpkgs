{ stdenv, buildPythonPackage, pythonOlder, fetchPypi, darwin, python,
pyobjc-core, pyobjc-framework-Cocoa }:

buildPythonPackage rec {
  pname = "pyobjc-framework-AppleScriptObjC";
  version = "6.2.2";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1cnxjb64ggznwc86b6wgr1lr17zywljndifkrixwarm20bhm272q";
  };

  postPatch = ''
    # Hard code correct SDK version
    substituteInPlace pyobjc_setup.py \
      --replace 'os.path.basename(data)[6:-4]' '"${darwin.apple_sdk.sdk.version}"'
  '';

  propagatedBuildInputs = [
    pyobjc-core
    pyobjc-framework-Cocoa
  ];

  # clang-7: error: argument unused during compilation: '-fno-strict-overflow'
  hardeningDisable = [ "strictoverflow" ];

  # show test names instead of just dots
  checkPhase = ''
    runHook preCheck

    ${python.interpreter} setup.py test --verbosity=3

    runHook postCheck
  '';

  preCheck = ''
    # testConstants in PyObjCTest.test_cfsocket.TestSocket returns: Segmentation fault: 11
    export DYLD_FRAMEWORK_PATH=/System/Library/Frameworks
  '';

  meta = with stdenv.lib; {
    description = "Wrappers for the framework AppleScriptObjC on Mac OS X";
    homepage = "https://pythonhosted.org/pyobjc-framework-AppleScriptObjC/";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
