# floating point modules

## run EDA flow

modify hardware unit name in `/flow/main.py`:

``` python
top_module = 'fp_mult_exp_cal' # e.g. fp32_naive_divider
```

then run `/flow/main.py`

get `result.json` in `/result/<module name>` dir

## run PPA estimator script

using EDA flow result to modify params in `/scripts/ModulePPA.py`

then run `/scripts/OnlineSoftmaxUnit.py`, `scripts/ReductionUnit.py` to get micro arc PPAs.

## references

* <https://github.com/dawsonjon/fpu.git>