{ stdenv, buildPythonPackage, pythonOlder, fetchPypi, darwin, python,
pyobjc-core }:

buildPythonPackage rec {
  pname = "pyobjc-framework-Cocoa";
  version = "6.2.2";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1hvzkf4zq0cipss2h95hwz1ymclncgww8d3hx85j97bqzfc1p0km";
  };

  patches = [ ./tests.patch ];

  postPatch = ''
    # Hard code correct SDK version
    substituteInPlace pyobjc_setup.py \
      --replace 'os.path.basename(data)[6:-4]' '"${darwin.apple_sdk.sdk.version}"'
  '';

  buildInputs = with darwin.apple_sdk.frameworks; [
    AppKit
    Foundation
  ];

  propagatedBuildInputs = [
    pyobjc-core
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

    # symlink TestSupport.py because Python only checks the first directory in PYTHONPATH
    ln -s "${pyobjc-core.outPath}/lib/${python.libPrefix}/site-packages/PyObjCTools/TestSupport.py" Lib/PyObjCTools/TestSupport.py
  '';

  postCheck = ''
    # If the symlink exists in the final package the modules can't be used in a Python environment because the file would be duplicated
    rm Lib/PyObjCTools/TestSupport.py
  '';
  meta = with stdenv.lib; {
    description = "Wrappers for the framework Cocoa on Mac OS X";
    homepage = "https://pythonhosted.org/pyobjc-framework-Cocoa/";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
