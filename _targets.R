library(targets)
# This is an example _targets.R file. Every
# {targets} pipeline needs one.
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(summary) to view the results.

# Define custom functions and other global objects.
# This is where you write source(\"R/functions.R\")
# if you keep your functions in external scripts.

source("R/functions.R")
source("_packages.R")
options(timeout=24*60*60) # let things download for at least 24 hours (important while on slow internet connection)
options(download.file.method = "libcurl")

#tar_invalidate(pages)
#tar_invalidate(index_et_al)
#tar_invalidate(about)
#tar_invalidate(sparklines)
#tar_invalidate(state_pages)
#tar_invalidate(pages_new)
#tar_invalidate(comparison_table)

# End this file with a list of target objects.
list(
 tar_target(db_from_access, CreateDBFromAccess()),
 tar_target(college_chosen_comparison_table, CreateComparisonNetwork(db_from_access, comparison_table)),
 tar_target(maxcount, Inf),
 tar_target(exclude_no_degrees, TRUE), # exclude institutions that do not grant degrees
 tar_target(ipeds_directly, GetIPEDSDirectly()),
 tar_target(ipeds_direct_and_db, AggregateDirectIPEDSDirect(ipeds_directly)),
 tar_target(comparison_table_core, CreateComparisonTables(ipeds_direct_and_db, exclude_no_degrees)),
 tar_target(comparison_table_mountain, AppendDistanceToMountains(comparison_table_core)),
 tar_target(comparison_table_slow_updating, AppendVaccination(AppendCATravelBan(AppendAAUPCensure(comparison_table_mountain)))),
 tar_target(population_by_state_by_age, GetStatePopulationByAge()),
 tar_target(comparison_table_prefilter, ReorderComparisonTable(AppendDiversityMetrics(AppendSourcesOfStudents(AppendTransRisk(AppendBiome(AppendAbortion(AppendGunLaws(AppendMarriageRespect(AppendContraceptiveSupport(comparison_table_slow_updating)))))))))),
 tar_target(comparison_table, PersonalFilter(comparison_table_prefilter)),
 tar_target(index_table, CreateIndexTable(comparison_table)),
 tar_target(weatherspark, GetWeathersparkLinks()),
 tar_target(life_expectancy, GetLifeExpectancy()),
 tar_target(life_expectancy_plots, CreateLifeExpectancyPlots(life_expectancy)),
 tar_target(fields_and_majors, GetFieldsAndMajors(comparison_table, ipeds_direct_and_db, CIPS_codes)),
 tar_target(saved_fields_and_majors, save(fields_and_majors, file='data/fields_and_majors.rda')),
 #tar_target(pages_new, RenderInstitutionPagesNew(comparison_table, fields_and_majors, maxcount=maxcount, CIPS_codes=CIPS_codes, weatherspark=weatherspark, yml=yml, index_table=index_table, life_expectancy=life_expectancy, population_by_state_by_age=population_by_state_by_age)),
 tar_target(institution_unitid, unique(comparison_table$`UNITID Unique identification number of the institution`)),
 tar_target(institution_rmd, command="_institution.Rmd", format="file"),
 tar_target(comparison_table_live, FilterComparisonTableForLive(comparison_table)),
 
 #tar_target(pages_new, RenderSingleInstitutionPage(institution_unitid='166027', comparison_table=comparison_table_live, fields_and_majors=fields_and_majors, maxcount=maxcount, CIPS_codes=CIPS_codes, weatherspark=weatherspark, yml=yml, index_table=index_table, life_expectancy=life_expectancy, population_by_state_by_age=population_by_state_by_age, institution_rmd=institution_rmd, institution_rmd_path="_institution_new.Rmd", college_chosen_comparison_table=college_chosen_comparison_table)) ,# for debugging changes
 
 
 tar_target(pages_comparison, RenderInstitutionPagesComparison(comparison_table, fields_and_majors, maxcount=40, CIPS_codes, yml, index_table, population_by_state_by_age, college_chosen_comparison_table)),

#  tar_target(
# 	pages_new, 
# 	RenderSingleInstitutionPage(institution_unitid, comparison_table=comparison_table_live, fields_and_majors=fields_and_majors, maxcount=maxcount, CIPS_codes=CIPS_codes, weatherspark=weatherspark, yml=yml, index_table=index_table, life_expectancy=life_expectancy, population_by_state_by_age=population_by_state_by_age, institution_rmd=institution_rmd, college_chosen_comparison_table=college_chosen_comparison_table),
# 	pattern=map(institution_unitid)
#  ),

 tar_target(CIPS_codes, GetCIPCodesExplanations()),
 tar_target(yml, CreateYMLForSite(CIPS_codes)),
 tar_target(field_pages, RenderFieldPages(CIPS_codes, fields_and_majors, yml)),
 tar_target(majors, RenderMajorsPages(fields_and_majors, CIPS_codes, yml, maxcount)),
 tar_target(field_data, GetFieldData(fields_and_majors)),
 tar_target(index_et_al, RenderIndexPageEtAl(pages_new, index_table, yml, CIPS_codes, comparison_table, fields_and_majors, field_data))

)
