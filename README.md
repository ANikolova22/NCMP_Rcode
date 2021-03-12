# NCMP_Rcode

Sustainable Development Goals, UK reporting development.

Collaborative R code to source new data or improve proxy SDG indicators 2.2.1 and 2.2.2
The methodology is specified by WHO, using specific standards on [height-for-age](https://www.who.int/tools/child-growth-standards/standards/length-height-for-age) and [weight-for-height](https://www.who.int/tools/child-growth-standards/standards/weight-for-length-height).

There is a dedicated R package ["anthro"](https://cran.r-project.org/web/packages/anthro/anthro.pdf) developed by WHO, which has a function (anthro_prevalence) to perform calculations and output the data as needed for the indicator reporting. This project develops a script to use the WHO package with the NCMP data. The R code is developed by the ONS, SDG team and delivered to PHE to run on NCMP data. The purpose is to avoid direct access to potentially sensitive data.
The raw data is not accessible, so the code is developed and tested on publicly available suppressed tables from [NHS Digital](https://digital.nhs.uk/data-and-information/publications/statistical/national-child-measurement-programme/2018-19-school-year).

The key steps of the scripts aim to produce headline data for indicators 2.2.1 and 2.2.2, including an additional disaggregation using the Index of multiple deprivation (IMD) variable (based on school location). In order to do what with the WHO R package, the IMD variable in the NCMP data is recoded from deciles into quintiles.

When running the main script, the file with the main data (not included in this repository) should be located one directory up from the current working directory of the R code.

