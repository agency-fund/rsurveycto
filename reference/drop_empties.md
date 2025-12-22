# Drop empty columns from a data.table

An empty column is one whose only values are `NA` or "".

## Usage

``` r
drop_empties(d)
```

## Arguments

- d:

  `data.table`.

## Value

`d` modified by reference, invisibly.

## Examples

``` r
library('data.table')
d = data.table(w = 3:4, x = c('', 'foo'), y = c(NA, NA), z = c(NA, ''))
drop_empties(d)
#>        w      x
#>    <int> <char>
#> 1:     3       
#> 2:     4    foo
```
