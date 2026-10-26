
# iPastoralist

**An R package for vegetation data analysis, phytopastoral assessment,
and phytosociological classification.**

*iPastoralist* provides tools for processing, analyzing, and classifying
plant communities, with particular emphasis on grassland and pasture
vegetation.

The package supports botanical data collected using both **point-quadrat
(point-intercept)** and **phytosociological** survey methods,
integrating biodiversity assessment, ecological indicators, pastoral
evaluation, and numerical vegetation classification.

## Main features

### 1. Vegetation data preparation and conversion

- **Point-quadrat data processing:** convert species frequency of
  occurrence into relative abundance and estimated percentage cover,
  including optional treatment of occasional species
  (`vegetation_abundance()`).
- **Phytosociological data conversion:** transform visually estimated
  species cover into Braun-Blanquet, Van der Maarel, and numerical
  cover-abundance scales (`PhytoCover()`).

### 2. Vegetation characterization

- **Biodiversity assessment:** calculate species richness, Shannon
  diversity, Effective Number of Species, and evenness
  (`biodiversity()`).
- **Pastoral Value:** assess the forage potential of grassland and
  pasture vegetation (`pastoral_value()`).
- **Ecological indicator values:** calculate Ellenberg and Landolt
  community-level indices, with optional abundance weighting
  (`ecological_indexes()`).
- **Floristic composition:** extract the most abundant species for
  individual vegetation surveys (`first_ten_species()`).

### 3. Vegetation classification and interpretation

*iPastoralist* provides tools supporting numerical vegetation
classification and the characterization of resulting vegetation groups.

Main functionalities include:

- **Numerical classification:** identify vegetation groups based on
  floristic similarity.
- **Classification evaluation:** compare alternative partitions and
  support the selection of the number of vegetation groups.
- **Species characterization:** identify diagnostic, constant, dominant,
  and companion species.
- **Synoptic vegetation tables:** summarize species frequencies and
  floristic differences among vegetation groups.
- **Phytopastoral interpretation:** characterize grassland and pasture
  types according to their botanical composition, ecological properties,
  and pastoral characteristics.
- **Phytosociological interpretation:** support the identification and
  comparison of vegetation units and their possible attribution to
  established syntaxonomic schemes.

These tools facilitate **reproducible vegetation classification
workflows**, combining numerical analyses with ecological and
expert-based interpretation.

## Installation

Install *iPastoralist* directly from GitHub using the `pak` package:

\`\`\`r id=“m0vzq8” \# Install pak (if needed) install.packages(“pak”)

# Install iPastoralist

pak::pak(“MarcoPittarello/iPastoralist”)

# Load the package

library(iPastoralist) \`\`\`

## Documentation

Detailed descriptions of the functions, methodological explanations, and
examples are available in the package documentation.

- **Website and function reference:** [iPastoralist
  website](https://marcopittarello.github.io/iPastoralist/)
- **Introduction and tutorials:** available in the website’s Articles
  section.
- **Source code:** [GitHub
  repository](https://github.com/MarcoPittarello/iPastoralist)

## Author

**Marco Pittarello**

## License

GPL-3
