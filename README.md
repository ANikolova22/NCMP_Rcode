# NCMP_Rcode

Sustainable Development Goals, UK reporting development.

Collaborative R code to source new data or improve proxy SDG indicators 2.2.1 and 2.2.2
The methodology is specified by WHO, using specific standards on [height-for-age](https://www.who.int/tools/child-growth-standards/standards/length-height-for-age) and [weight-for-height](https://www.who.int/tools/child-growth-standards/standards/weight-for-length-height).

The R code is developed by ONS, SDG team and delivered to PHE to run on NCMP data. The purpose is to avoid direct access to potentially sensitive data.
The raw data is not accessible, so the code is developed based on publicly available suppressed tables from [NHS Digital](https://digital.nhs.uk/data-and-information/publications/statistical/national-child-measurement-programme/2018-19-school-year).

The main R code is contained in NCMP.R and it reads information from the two csv files, so they should be placed in the same working directory. The file with the main data (not included in this repository) should be located one directory up from the current working directory of the R code.