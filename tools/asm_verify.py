"""Wrapper: lo strumento vive in nesrecomp/tools/mmc5/asm_verify.py (backend MMC5 di nesrecomp)."""
import os, sys, runpy, importlib.util
_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "nesrecomp", "tools", "mmc5", "asm_verify.py")
_d = os.path.dirname(_p)
if _d not in sys.path:
    sys.path.insert(0, _d)
if __name__ == "__main__":
    runpy.run_path(_p, run_name="__main__")
else:
    _spec = importlib.util.spec_from_file_location("_mmc5_asm_verify", _p)
    _m = importlib.util.module_from_spec(_spec)
    sys.modules["_mmc5_asm_verify"] = _m
    _spec.loader.exec_module(_m)
    globals().update({k: v for k, v in vars(_m).items() if not k.startswith("__")})
