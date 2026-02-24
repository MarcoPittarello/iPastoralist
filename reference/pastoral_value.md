# Computation of Pastoral Value (PV)

Computation of PV from a database with SRA, either SRA_fo or
SRA_SC.fo.occ (see [vegetation_abundance](vegetation_abundance.md)). See
@details for theoretical information

## Usage

``` r
pastoral_value(SRA_data, isq_data)
```

## Arguments

- SRA_data:

  database with SRA values, either 'SRA_fo' or 'SRA_SC.fo.occ' (see
  [vegetation_abundance](vegetation_abundance.md)). Database class must
  be *data.frame*

- isq_data:

  database with ISQ values. Species without an ISQ have to be specified
  with 999.Database class must be *data.frame*

## Value

database with PV computed per each survey

## Details

The forage productivity and quality can be expressed through the
Pastoral Value (PV), which is a unique and synthetic index derived from
sward botanical composition summarizing forage yield, quality, and
palatability for livestock (Daget and Poissonet, 1969, Pittarello et al.
2018, 2020).  

PV, which ranges from 0 to 100, is computed according to the following
formula (Daget and Poissonet, 1971):

PV = (SRAi ISQi) 0.2

where:

- ISQ: is an Index of specific quality attributed to each species which
  epends on the preference, morphology, structure, and productivity of
  the plant species. It ranges from 0 (low) to 5 (high) (Daget and
  Poissonet, 1971; Cavallero et al., 2007).

- SRA: Species Relative Abundance for each species within a survey
  computed as either 'SRA_fo' or 'SRA_SC.fo.occ' (see
  [vegetation_abundance](vegetation_abundance.md)) attributed each
  species an Index of specific quality (ISQ)

## References

- Cavallero, A., Aceto, P., Gorlier, A., Lombardi, G., Lonati, M.,
  Martinasso, B., Tagliatori, C., (2007). I tipi pastorali delle Alpi
  piemontesi. (Pasture types of the Piedmontese Alps). Alberto Perdisa
  Editore. p. 467, Bologna.

- Daget, P., Poissonet, J., 1969. Analyse phytologique des praries,
  Centre Nat. ed, Applications agronomiques. Montpellier - France

- Daget, P., Poissonet, J., 1971. A method of plant analysis of
  pastures. Ann. Agron. 22, 5–41.

- Pittarello, M., Lonati, M., Gorlier, A., Perotti, E., Probo, M.,
  Lombardi, G., 2018. Plant diversity and pastoral value in alpine
  pastures are maximized at different nutrient indicator values. Ecol.
  Indic. 85, 518–524. https://doi.org/10.1016/j.ecolind.2017.10.064

- Pittarello, M., Lonati, M., Ravetto Enri, S., Lombardi, G., 2020.
  Environmental factors and management intensity affect in different
  ways plant diversity and pastoral value of alpine pastures. Ecol.
  Indic. 115, 106429. https://doi.org/10.1016/j.ecolind.2020.106429

## Examples
