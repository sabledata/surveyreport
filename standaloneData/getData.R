#  source("c:/github/surveyreport/standaloneData/getData.R")

if(!(require(RODBC))) install.packages("RODBC") 

path<-"c:/github/surveyreport/standaloneData/"
yr <- 2018

# ------------SQL SERVER LOAD-------------------------

GetSQLData <- function(strSQL,strDbName) { 
   require(RODBC)   
   cnn <- odbcDriverConnect(paste("Driver={SQL Server};Server=DFBCV9TWVASP001;",
        "Database=",strDbName,";Trusted_Connection=Yes",sep=""))
   dat <- sqlQuery(cnn, strSQL)
   odbcClose(cnn)
   return(dat) 
}

# temporary -------------------------------

history     <- paste("select dbo.SURVEY_SITE_HISTORIC.SURVEY_SERIES_ID, YEAR(dbo.SURVEY_SITE_HISTORIC.SURVEY_START_DATE) AS Year,  ",
                       " dbo.SURVEY_SITE_HISTORIC.BLOCK_DESIGNATION,  dbo.SURVEY_SITE_HISTORIC.SELECTION_TYPE_CODE, dbo.SURVEY_SITE_HISTORIC.SELECTION_IND, ",
                      "dbo.SITE_STATUS.SITE_STATUS_CODE AS Count,    dbo.SITE_STATUS.SITE_STATUS_DESCRIPTION  ", 
                      "FROM     dbo.SURVEY_SITE_HISTORIC INNER JOIN  dbo.SITE_STATUS ON dbo.SURVEY_SITE_HISTORIC.STATUS_CODE ",
                     "= dbo.SITE_STATUS.SITE_STATUS_CODE  WHERE  (dbo.SURVEY_SITE_HISTORIC.SURVEY_SERIES_ID = 43)  AND ",
                     "(YEAR(dbo.SURVEY_SITE_HISTORIC.SURVEY_START_DATE)  in(2018, 2019))", sep="")
   hist          <- GetSQLData(history,"GFBioSQL")  
   write.table( hist, file = paste(path,"history.csv",sep=''),row.names=FALSE, na="",col.names=TRUE,  sep=",")

#index -----------------------------

   details     <- paste("select VESSEL_NAME as Vessel, CAPTAIN, ",
                        "LEFT(CONVERT(varchar, START_DATE, 100), 7) + ' - ' ",
                        "+ LEFT(CONVERT(varchar, END_DATE, 100), 7) AS [Trip Dates], ",
                        "COUNT([SET]) AS [Count of Sets] from  dbo.GFBIO_RESEARCH_TRIPS ",
                        "where year IN( ",yr,",",yr+1,") group by ",
                        "VESSEL_NAME, CAPTAIN,  ",
                        "LEFT(CONVERT(varchar, START_DATE, 100),7) + ' - ' + ",
                        "LEFT(CONVERT(varchar, END_DATE, 100),7)", sep="")
   sd          <- GetSQLData(details,"Sablefish")  # -- survey details
   write.table( sd, file = paste(path,"index01_SurveyDetails.csv",sep=''),row.names=FALSE, na="",col.names=TRUE,  sep=",")

   avgC        <- paste("select ROUND(AVG(TOTAL), 0) AS YrAvg from dbo.TableA2_Annual_sablefish_Landing_in_Can_waters_2 ",
                        " where (year <= ", yr+1, ") and (year >= ",yr - 8,")", sep="")
   avgTen       <- GetSQLData(avgC,"Sablefish")    # -- average catch last 10 years
  write.table( avgTen, file = paste(path,"index02_10YearAvgCatch.csv",sep=''),row.names=FALSE, na="",col.names=TRUE,  sep=",")

   tp          <- paste("select ROUND(TRAP / TOTAL * 100, 0) AS TrapPer from dbo.TableA2_Annual_sablefish_Landing_in_Can_waters_2 ",  
                        " where  (year = ", yr, ")  group by ROUND(TRAP / TOTAL * 100, 0), TOTAL", sep="")
   trapP       <- GetSQLData(tp,"Sablefish")        # -- trap gear catch ratio
  write.table( trapP, file = paste(path,"index03_TrapRatio.csv",sep=''),row.names=FALSE, na="",col.names=TRUE,  sep=",")

   lp          <- paste("select  ROUND(LONGLINE / TOTAL * 100, 0) AS LonglinePer from ",  
                         " dbo.TableA2_Annual_sablefish_Landing_in_Can_waters_2  where  (year = ", yr, 
                         ") group by ROUND(LONGLINE / TOTAL * 100, 0), TOTAL", sep="")
   LonglineP   <- GetSQLData(lp,"Sablefish")        # -- longline gear catch ratio
  write.table( LonglineP, file = paste(path,"index04_LonglineRatio.csv",sep=''),row.names=FALSE, na="",col.names=TRUE,  sep=",")

   tp          <- paste("select ROUND(TRAP / TOTAL * 100, 0) AS TrapPer from dbo.TableA2_Annual_sablefish_Landing_in_Can_waters_2 ",  
                        " where  (year = ", yr+1, ")  group by ROUND(TRAP / TOTAL * 100, 0), TOTAL", sep="")
   trapP2       <- GetSQLData(tp,"Sablefish")        # -- trap gear catch ratio
  write.table( trapP2, file = paste(path,"index05_TrapRatio.csv",sep=''),row.names=FALSE, na="",col.names=TRUE,  sep=",")

   lp          <- paste("select  ROUND(LONGLINE / TOTAL * 100, 0) AS LonglinePer from ",  
                         " dbo.TableA2_Annual_sablefish_Landing_in_Can_waters_2  where  (year = ", yr+1, 
                         ") group by ROUND(LONGLINE / TOTAL * 100, 0), TOTAL", sep="")
   LonglineP2   <- GetSQLData(lp,"Sablefish")        # -- longline gear catch ratio
  write.table( LonglineP2, file = paste(path,"index06_LonglineRatio.csv",sep=''),row.names=FALSE, na="",col.names=TRUE,  sep=",")

#  appendix--------------------------------------

  dtBW   <- paste("exec dbo.procRKnitr_SurveyTrips ",yr+1,sep="")
   trip   <- GetSQLData(dtBW,"Sablefish")
   write.table(trip, file = paste(path,"appendixA.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   srvyset <-  paste("dbo.procRReport_Survey_SetDetails ",yr,",1,",setcnt, sep="")
   ssdat   <-  GetSQLData(srvyset,"Sablefish")
   write.table( ssdat, file = paste(path,"appendixC.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   srvyset <-  paste("dbo.procRReport_Survey_SetDetails ",yr+1,",1,",setcnt, sep="")
   ssdat   <-  GetSQLData(srvyset,"Sablefish")
   write.table( ssdat, file = paste(path,"appendixD.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   trap       <- paste("dbo.procRReport_Survey_TrapUse ",yr,",1,",setcnt, sep="")
   trapdat    <- GetSQLData(trap,"Sablefish")
   write.table(trapdat, file = paste(path,"appendixE.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   trap       <- paste("dbo.procRReport_Survey_TrapUse ",yr+1,",1,",setcnt, sep="")
   trapdat    <- GetSQLData(trap,"Sablefish")
   write.table(trapdat, file = paste(path,"appendixF.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   samples              <-  paste("dbo.procReport_Survey_SampleDetails ",yr,",1,",setcnt, sep="")
   surveyspec           <-  GetSQLData(samples,"Sablefish")
   write.table( surveyspec, file = paste(path,"appendixG.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   yr2 <- yr + 1
   samples2       <-  paste("dbo.procReport_Survey_SampleDetails ",yr2,",1,",setcnt2, sep="")
   surveyspec2    <-  GetSQLData(samples2,"Sablefish")
   write.table(surveyspec2, file = paste(path,"appendixH.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

     othersamples    <-  paste( "select species_name, [SET], [Len Sample Count], [weight_count],[Sex Sample Count], ",
                                    "[Maturity Sample Count], [Otolith Sample Count], [DNA Sample Count], ",
                                    "Sample_count, [Proportion Males],  ",
                                    "round([Male Mean Fork Len(mm)],0) as malelen, round([Female Mean Fork Len(mm)],0) as femlen,  ", 
                                    " round([NoSexMeanLen(mm)],0) as nosexlen, bsre.Rougheye, bsre.Blackspotted, bsre.Hybrid ",
                                    "FROM  (SELECT  year, TRIP_ID, FE_MAJOR_LEVEL_ID, SPECIES_CODE, ",
                                    "SUM(re) AS Rougheye, SUM(bs) AS Blackspotted, SUM(hyb) AS Hybrid ",
                                    "FROM  (SELECT  year, TRIP_ID, FE_MAJOR_LEVEL_ID, SPECIES_CODE, ",
                                    "CASE WHEN EXISTENCE_ATTRIBUTE_CODE = 16 THEN 1 ELSE 0 END AS re, ",
                                    "CASE WHEN EXISTENCE_ATTRIBUTE_CODE = 17 THEN 1 ELSE 0 END AS bs, ",
                                    "CASE WHEN EXISTENCE_ATTRIBUTE_CODE = 31 THEN 1 ELSE 0 END AS hyb, ",
                                    "SPECIMEN_ID ",
                                    "FROM  dbo.gfbio_species_guess) AS bs ",
                                    "GROUP BY year, TRIP_ID, FE_MAJOR_LEVEL_ID, SPECIES_CODE) AS bsre RIGHT OUTER JOIN ",
                                    "dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH ON bsre.TRIP_ID = ",              
                                    "dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH.TRIP_ID ",
                                    "AND bsre.FE_MAJOR_LEVEL_ID = dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH.[SET] AND bsre.SPECIES_CODE = ",                                        "dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH.species ", 
                                    "where (dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH.Year = ",yr, 
                                    ") order by species,[SET]", sep="")
   otherspec             <-  GetSQLData(othersamples,"Sablefish")
   write.table( otherspec , file = paste(path,"appendixI.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   othersamples          <-  paste( "select species_name, [SET], [Len Sample Count], [weight_count],[Sex Sample Count], ",
                                    "[Maturity Sample Count], [Otolith Sample Count], [DNA Sample Count], ",
                                    "Sample_count, [Proportion Males],  ",
                                    "round([Male Mean Fork Len(mm)],0) as malelen, round([Female Mean Fork Len(mm)],0) as femlen,  ", 
                                    " round([NoSexMeanLen(mm)],0) as nosexlen, bsre.Rougheye, bsre.Blackspotted, bsre.Hybrid ",
                                    "FROM  (SELECT  year, TRIP_ID, FE_MAJOR_LEVEL_ID, SPECIES_CODE, ",
                                    "SUM(re) AS Rougheye, SUM(bs) AS Blackspotted, SUM(hyb) AS Hybrid ",
                                    "FROM  (SELECT  year, TRIP_ID, FE_MAJOR_LEVEL_ID, SPECIES_CODE, ",
                                    "CASE WHEN EXISTENCE_ATTRIBUTE_CODE = 16 THEN 1 ELSE 0 END AS re, ",
                                    "CASE WHEN EXISTENCE_ATTRIBUTE_CODE = 17 THEN 1 ELSE 0 END AS bs, ",
                                    "CASE WHEN EXISTENCE_ATTRIBUTE_CODE = 31 THEN 1 ELSE 0 END AS hyb, ",
                                    "SPECIMEN_ID ",
                                    "FROM  dbo.gfbio_species_guess) AS bs ",
                                    "GROUP BY year, TRIP_ID, FE_MAJOR_LEVEL_ID, SPECIES_CODE) AS bsre RIGHT OUTER JOIN ",
                                    "dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH ON bsre.TRIP_ID = ", 
                                    "dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH.TRIP_ID ",
                                    "AND bsre.FE_MAJOR_LEVEL_ID = dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH.[SET] AND bsre.SPECIES_CODE = ",                                        " dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH.species ", 
                                    " WHERE (dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH.Year = ",yr+1, ") order by species,[SET]", sep="")
   otherspec             <-  GetSQLData(othersamples,"Sablefish")
   write.table( otherspec , file = paste(path,"appendixJ.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

#---tables  -----------------------------------------------------------

  dtSP   <- paste("exec procRReport_SpeciesSummary ",yr," ,'StRS'",sep="")
  datSP  <- GetSQLData(dtSP,"Sablefish")
  write.table(datSP, file = paste(path,"table03_StRSspecies.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

  dtSP   <- paste("exec procRReport_SpeciesSummary ",yr," ,'INLET STANDARDIZED'",sep="")
  datSP  <- GetSQLData(dtSP,"Sablefish")
  write.table(datSP, file = paste(path,"table04_InletSpecies.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

  dtSP   <- paste("exec procRReport_SpeciesSummary ", yr+1," ,'StRS'",sep="")
  datSP  <- GetSQLData(dtSP,"Sablefish")
  write.table(datSP, file = paste(path,"table05_StRSspecies.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

  dtSP   <- paste("exec procRReport_SpeciesSummary ",yr+1," ,'INLET STANDARDIZED'",sep="")
  datSP  <- GetSQLData(dtSP,"Sablefish")
  write.table(datSP, file = paste(path,"table06_InletSpecies.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

  dtBW  <-  paste("select [Release year] as [Year], Total_released as [Release], ",
                          "Rec_1991 as [91], Rec_1992 as [92], Rec_1993 as [93], ",
                          "Rec_1994 as [94], Rec_1995 as [95], Rec_1996 as [96], ",
                          "Rec_1997 as [97], Rec_1998 as [98], Rec_1999 as [99], ",
                          "Rec_2000 as [00], Rec_2001 as [01], Rec_2002 as [02], ",
                          "Rec_2003 as [03], Rec_2004 as [04], Rec_2005 as [05], ",
                          "Rec_2006 as [06], Rec_2007 as [07], Rec_2008 as [08], ",
                          "Rec_2009 as [09], Rec_2010 as [10], Rec_2011 as [11], ",
                          "Rec_2012 as [12], Rec_2013 as [13], Rec_2014 as [14], ",
                          "Rec_2015 as [15], Rec_2016 as [16], Rec_2017 as [17], ",
                          "Rec_2018 as [18], Rec_2019 as [19], Total_recovered as [Total], No_recovery_year as [No Year] ",
                          "from dbo.WEB_TAG_REVIEW order by [Release year]",sep="")
   datag <-  GetSQLData(dtBW,"FishTag")
   write.table(datag, file = paste(path,"table09_TaggedFishCounts.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   tagGMUc       <-  paste("select * from q_Fish_Tag_Rel_Rec_by_GMU ")
   tagGMU        <-  GetSQLData(tagGMUc,"FishTag")
   write.table(tagGMU, file = paste(path,"table10_TagGMU.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

#---figures -------------------------------------------------------------------------------------------------------------------------------------

   dtStRS    <-    " select  * from dbo.GENERIC_GFBIO_TRAPS where [Spatial.Stratum] not like '%Quatsino Sound%' order by year"
   datStRS  <-    GetSQLData(dtStRS,"Sablefish")
   write.table(datStRS , file = paste(path,"figure06_TrapCPUE.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

  cpuedt <- "SELECT  * FROM dbo.GENERIC_GFBIO_TRAPS where [Spatial.Stratum] not like '%Quatsino Sound%' "
  cpuedat<- GetSQLData(cpuedt,"Sablefish") 
  write.table(cpuedat, file = paste(path,"figure07_InletCPUE.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

     lenstats  <- "exec procRReport_Survey_LenAvg"
     dat       <- GetSQLData(lenstats,"Sablefish")
    write.table(dat , file = paste(path,"figure08_MeanLength.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

    lenWT           <-   "exec procR_Survey_Sablefish_LenWt_shiny"
    lenWTdat1  <-    GetSQLData(lenWT,"Sablefish")
    write.table(lenWTdat1, file = paste(path,"figure09_LengthWeight.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

    sqlpolar  <- paste("select YEAR, SABLE_AREA_GROUP, SABLE_DEPTH_GROUP, ROUND(countSub / total * 100, 1) AS subL, ",
             " ROUND(countLeg / total * 100, 1) AS Leg, combo,combo + cast(YEAR as varchar) as combo2,(cast(right(sable_area_group,1) as int) + ", 
             " cast(right(sable_area_group,1) as int) + cast(right(sable_depth_group,1) as int) + ", 
             " cast(right(sable_area_group,1)  as int)-4 )  as polarorder from   ", 
             " (select YEAR, SABLE_AREA_GROUP, SABLE_DEPTH_GROUP, SUM(NULLIF (subl, 0.0)) AS countSub, ",
             " SUM(NULLIF (leg, 0.0)) AS countLeg, SUM(subl) + SUM(leg) AS total, SABLE_AREA_GROUP + SABLE_DEPTH_GROUP as combo ",
             " from (select YEAR, SABLEFISH_SURVEY_IND, SABLE_AREA_GROUP, SABLE_DEPTH_GROUP, SPECIMEN_ID, SPECIMEN_SEX_CODE,  ",  
             " CASE when Fork_Length <= 550 then 1.0 ELSE 0.0 END AS subl, CASE when Fork_Length > 550 THEN 1.0 ELSE 0.0 END AS leg  ",
             " from dbo.GFBIO_SABLEBIO_VW where (SABLEFISH_SURVEY_IND = 1) AND  ",
             " (SABLE_AREA_GROUP IN (N's1', N's2', N's3', N's4', N's5')) ) AS LS group by SABLE_AREA_GROUP, SABLE_DEPTH_GROUP, YEAR ) AS LS1 ",
             " order by YEAR, SABLE_AREA_GROUP, SABLE_DEPTH_GROUP")

    polarsumm <-   paste("select YEAR, SABLE_AREA_GROUP, SABLE_DEPTH_GROUP from  (select YEAR, SABLE_AREA_GROUP, SABLE_DEPTH_GROUP,  ",
                      " SUM(NULLIF (subl, 0.0)) AS countSub, SUM(NULLIF (leg, 0.0)) AS countLeg, SUM(subl) + SUM(leg) AS total,  ",
                      " SABLE_AREA_GROUP + SABLE_DEPTH_GROUP AS combo from (select YEAR, SABLEFISH_SURVEY_IND, SABLE_AREA_GROUP, ",
                      " SABLE_DEPTH_GROUP, SPECIMEN_ID, SPECIMEN_SEX_CODE, CASE WHEN Fork_Length <= 550 THEN 1.0 ELSE 0.0 END AS subl, ",
                      " case WHEN Fork_Length > 550 THEN 1.0 ELSE 0.0 END AS leg from dbo.GFBIO_SABLEBIO_VW ",
                      " where (SABLEFISH_SURVEY_IND = 1) AND (SABLE_AREA_GROUP IN (N's1', N's2', N's3', N's4', N's5'))) AS LS ",
                      " group by SABLE_AREA_GROUP, SABLE_DEPTH_GROUP, YEAR) AS LS1 ",
                      " where (ROUND(countSub / total * 100, 1) > 50)  group by YEAR, SABLE_AREA_GROUP, SABLE_DEPTH_GROUP ",
                      " order by YEAR, SABLE_AREA_GROUP, SABLE_DEPTH_GROUP")

    polar        <- GetSQLData(sqlpolar ,"Sablefish")
    polarsummary <- GetSQLData(polarsumm ,"Sablefish")   # view the results to be able to type into the summary

    write.table( polar , file = paste(path,"figure10_Polar.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")
    write.table(polarsummary, file = paste(path,"figure10_PolarSummary.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   dt   <-  paste("select * from Report_Survey_GFBIO_Age_MF_Prop where SetType='StRS' and Year<=", yr + 1, sep="")
   dat  <-  GetSQLData(dt,"Sablefish")
   write.table(dat, file = paste(path,"figure11_AgeBubblePlot.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

    sbecp        <- paste("select * from SEABIRD_ReportCoplot where Year in(",yr,",",yr+1,")",sep="")
    ctddat       <- GetSQLData(sbecp,"Sablefish")
    write.table(ctddat, file = paste(path,"figure12_SeaBirdCoplot.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

       ctddt  <-  "select * from SEABIRD_ReportLinePlot"
       ctd    <-  GetSQLData(ctddt,"Sablefish") 
      write.table(ctd , file = paste(path,"figure13_SeaBirdLineplot.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

# ---- methods---------------------------------------------------------------------------------------------------------------------------------
   sense  <-  paste("select Year, SUM(SBE39) AS SBE39, SUM(HOBO) AS HOBO, SUM(CTD) AS CTD, SUM(CAM) AS CAM ",
                      "from dbo.Report_SBE_HOBO_IND group by Year having (Year =", yr,")", sep="")
   sensor  <-  GetSQLData(sense,"Sablefish")
  write.table(sensor, file = paste(path,"methods01_hobo.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   sense2 <-  paste("select Year, SUM(SBE39) AS SBE39, SUM(HOBO) AS HOBO, SUM(CTD) AS CTD, SUM(CAM) AS CAM ",
                      "from dbo.Report_SBE_HOBO_IND group by Year having (Year =", yr+1,")", sep="")
   sensor2  <-  GetSQLData(sense2,"Sablefish")
   write.table(sensor2, file = paste(path,"methods02_hobo2.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")


# -- results-----------------------------------------------------------------

  dtStRS   <-   " select  * from dbo.GENERIC_GFBIO_TRAPS order by year"  # -- must update view GENERIC_GFBIO_TRAPS
  datStRS  <-   GetSQLData(dtStRS,"Sablefish") 
   write.table(datStRS, file = paste(path,"results01_GenericTrapsCatchRates.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   topStRS      <- paste("select top (5) SPECIES_COMMON_NAME, SPECIES_SCIENCE_NAME, ",
                         "sum(CATCH_WEIGHT) AS catchkg ",
                         "from dbo.GFBIO_RESEARCH_CATCH ",
                         "group by SABLE_SET_TYPE, Year, SPECIES_CODE, ",
                         "SPECIES_COMMON_NAME, SPECIES_SCIENCE_NAME ",
                         "having (SABLE_SET_TYPE = N'StRS') and ",
                         "(SPECIES_CODE <> N'455') and (Year = ",yr,") ",
                         "order by catchkg DESC", sep="") 
   topStRSsp    <- GetSQLData(topStRS,"Sablefish") 
   write.table( topStRSsp, file = paste(path,"results02_Top5GroupStRS.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   topInlet     <- paste("select top (2) SPECIES_COMMON_NAME, SPECIES_SCIENCE_NAME, sum(CATCH_WEIGHT) AS catchkg
                          from dbo.GFBIO_RESEARCH_CATCH 
                          group by SABLE_SET_TYPE, Year, SPECIES_CODE, SPECIES_COMMON_NAME, SPECIES_SCIENCE_NAME
                          having (SABLE_SET_TYPE = N'INLET STANDARDIZED') and (SPECIES_CODE <> N'455') and (Year = ",yr,")
                          order by catchkg DESC", sep="")    
   topInletsp   <- GetSQLData(topInlet,"Sablefish")
  write.table(topStRSsp, file = paste(path,"results03_Top2GroupInlets.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   spc          <- paste("select dbo.fnIntegerToWords(SUM(CAST(Roundfish as int))) as tRound,  ",
                                "dbo.fnIntegerToWords(SUM(Rockfish))     as tRock,   ",
                                "dbo.fnIntegerToWords(SUM(Flatfish))     as tFlat,   ",
                                "dbo.fnIntegerToWords(SUM(Invertebrate)) as tInvert, ",
                                "dbo.fnIntegerToWords(SUM(Mammal))       as tMammal, ",
                                "dbo.fnIntegerToWords(SUM(Bird))         as tBird,   ",
                                "dbo.fnIntegerToWords(SUM(counter))      as total    ",
                                "from (select case when Fish = Rockfish or Fish = Flatfish then 0 ELSE Fish end AS Roundfish, ",
                                "Fish, Rockfish, Flatfish, Invertebrate, Mammal, Bird, ",
                                "SABLE_SET_TYPE, TRIP_ID, 1 AS counter, Year, SPECIES_CODE from dbo.GFBIO_RESEARCH_CATCH ",
                                "group by ",
                                "Fish, Rockfish, Flatfish, Invertebrate, Mammal, Bird, SABLE_SET_TYPE, Year, TRIP_ID,  ",
                                "case when Fish = Rockfish or Fish = Flatfish then 0 ELSE Fish end, SPECIES_CODE  ",
                                "having (SABLE_SET_TYPE = N'StRS') and (Year = ",yr,")) AS RC", sep="")
   strsSpCom    <- GetSQLData(spc,"Sablefish")
  write.table(strsSpCom , file = paste(path,"results04_TaxGroupStRS.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   spcI           <- paste("select dbo.fnIntegerToWords(SUM(CAST(Roundfish AS int))) AS tRound,   ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Rockfish),0))     AS tRock,    ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Flatfish),0))     AS tFlat,    ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Invertebrate),0)) AS tInvert,  ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Mammal),0))       AS tMammal,  ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Bird),0))         AS tBird,    ",
                                 "dbo.fnIntegerToWords(SUM(counter))                AS total     ",    
                         "from   (select CASE WHEN Fish = Rockfish or Fish = Flatfish THEN 0 ELSE Fish END AS Roundfish,  ",
                                 "Fish, Rockfish, Flatfish, Invertebrate, Mammal, Bird,       ",
                                 "SABLE_SET_TYPE, TRIP_ID, 1 AS counter, Year, SPECIES_CODE   ",
                                 "from dbo.GFBIO_RESEARCH_CATCH  ",
                                 "group by Fish, Rockfish, Flatfish, Invertebrate, Mammal, Bird, SABLE_SET_TYPE, Year, TRIP_ID, ",
                                 "CASE WHEN Fish = Rockfish or Fish = Flatfish THEN 0 ELSE Fish END, SPECIES_CODE ",
                                 "having (SABLE_SET_TYPE = N'INLET STANDARDIZED')       ",
                                 "and (Year = ",yr,")) AS RC",sep="")
   SpComI    <- GetSQLData(spcI,"Sablefish")
   write.table( SpComI, file = paste(path,"results05_TaxGroupInlet.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   topStRS.2      <- paste("select top (5) SPECIES_COMMON_NAME, SPECIES_SCIENCE_NAME, sum(CATCH_WEIGHT) AS catchkg ",
                          " from dbo.GFBIO_RESEARCH_CATCH ",
                          " group by ",
                          " SABLE_SET_TYPE, Year, SPECIES_CODE, SPECIES_COMMON_NAME, SPECIES_SCIENCE_NAME",
                          " having (SABLE_SET_TYPE = N'StRS') and (SPECIES_CODE <> N'455') and (Year = ",yr+1,") ",
                          " order by ",
                          " catchkg DESC", sep="") 
   topStRSsp.2    <- GetSQLData(topStRS.2,"Sablefish") 
   write.table(topStRSsp.2 , file = paste(path,"results06_Top5GroupStRS.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   topInlet.2     <- paste("select top (2) SPECIES_COMMON_NAME, SPECIES_SCIENCE_NAME, sum(CATCH_WEIGHT) AS catchkg ",
                           "from dbo.GFBIO_RESEARCH_CATCH  ",
                           "group by SABLE_SET_TYPE, Year, SPECIES_CODE, SPECIES_COMMON_NAME, SPECIES_SCIENCE_NAME ",
                           "having (SABLE_SET_TYPE = N'INLET STandARDIZED') ",
                           "and (SPECIES_CODE <> N'455') and (Year = ",yr+1,") ",
                           "order by catchkg DESC", sep="") 
   topInletsp.2   <- GetSQLData(topInlet.2,"Sablefish")
   write.table(topInletsp.2 , file = paste(path,"results07_Top2GroupInlets.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   spc.2        <- paste("select dbo.fnIntegerToWords(SUM(CAST(Roundfish AS int))) AS tRound,   ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Rockfish),0))     AS tRock,    ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Flatfish),0))     AS tFlat,    ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Invertebrate),0)) AS tInvert,  ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Mammal),0))       AS tMammal,  ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Bird),0))         AS tBird,    ",
                                 "dbo.fnIntegerToWords(SUM(counter))                AS total     ",    
                         "from   (select CASE WHEN Fish = Rockfish or Fish = Flatfish THEN 0 ELSE Fish END AS Roundfish,  ",
                                 "Fish, Rockfish, Flatfish, Invertebrate, Mammal, Bird,       ",
                                 "SABLE_SET_TYPE, TRIP_ID, 1 AS counter, Year, SPECIES_CODE   ",
                                 "from dbo.GFBIO_RESEARCH_CATCH  ",
                                 "group by Fish, Rockfish, Flatfish, Invertebrate, Mammal, Bird, SABLE_SET_TYPE, Year, TRIP_ID, ",
                                 "CASE WHEN Fish = Rockfish or Fish = Flatfish THEN 0 ELSE Fish END, SPECIES_CODE ",
                                 "having (SABLE_SET_TYPE = N'StRS')       ",
                                 "and (Year = ",yr+1,")) AS RC",sep="")
   strsSpCom.2    <- GetSQLData(spc.2,"Sablefish")
   write.table( strsSpCom.2 , file = paste(path,"results08_TaxGroupStRS.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")


   spc.2          <- paste("select dbo.fnIntegerToWords(SUM(CAST(Roundfish AS int))) AS tRound,   ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Rockfish),0))     AS tRock,    ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Flatfish),0))     AS tFlat,    ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Invertebrate),0)) AS tInvert,  ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Mammal),0))       AS tMammal,  ",
                                 "dbo.fnIntegerToWords(ISNULL(SUM(Bird),0))         AS tBird,    ",
                                 "dbo.fnIntegerToWords(SUM(counter))                AS total     ",    
                         "from   (select CASE WHEN Fish = Rockfish or Fish = Flatfish THEN 0 ELSE Fish END AS Roundfish,  ",
                                 "Fish, Rockfish, Flatfish, Invertebrate, Mammal, Bird,       ",
                                 "SABLE_SET_TYPE, TRIP_ID, 1 AS counter, Year, SPECIES_CODE   ",
                                 "from dbo.GFBIO_RESEARCH_CATCH  ",
                                 "group by Fish, Rockfish, Flatfish, Invertebrate, Mammal, Bird, SABLE_SET_TYPE, Year, TRIP_ID, ",
                                 "CASE WHEN Fish = Rockfish or Fish = Flatfish THEN 0 ELSE Fish END, SPECIES_CODE ",
                                 "having (SABLE_SET_TYPE = N'INLET STANDARDIZED')       ",
                                 "and (Year = ",yr+1,")) AS RC",sep="")
   strsSpCom.2    <- GetSQLData(spc.2,"Sablefish")
    write.table( strsSpCom.2 , file = paste(path,"results09_TaxGroupInlets.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

    catchStRS   <- paste("select rt.SABLE_SET_TYPE, ",
                         "SUM(sd.[Total Count])                           AS count, ",
                         "SUM(sd.[Recovered Number])                      AS tagagainlive, ",
                         "SUM(sd.[Recovered Dead Number])                 AS tagdead, ",
                         "SUM(sd.[Tagged Number] + sd.[Recovered Number]) AS tagrelease, " ,
                         "SUM(sd.[Fork Len Tag Sample Count])             AS taglengthsample,  " ,
                         "SUM(sd.Sample_count)                            AS samplecount " ,
                         "from dbo.GFBIO_RESEARCH_SAMPLE_DETAILS AS sd INNER JOIN " ,         
                         "dbo.GFBIO_SABLEBIO_TRIP_SET2 AS rt ON " ,
                         "sd.TRIP_ID = rt.TRIP_ID AND  sd.[SET] = rt.SET_NUMBER " ,
                         "where (sd.Year =", yr,") group by rt.SABLE_SET_TYPE",sep="") 
    countStRS   <- GetSQLData(catchStRS,"Sablefish")
    write.table( countStRS , file = paste(path,"results10_CountSamplesStRS.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")
    
    catchStRS2 <- paste("select rt.SABLE_SET_TYPE, ",
                         "SUM(sd.[Total Count])                           AS count, ",
                         "SUM(sd.[Recovered Number])                      AS tagagainlive, ",
                         "SUM(sd.[Recovered Dead Number])                 AS tagdead, ",
                         "SUM(sd.[Tagged Number] + sd.[Recovered Number]) AS tagrelease, " ,
                         "SUM(sd.[Fork Len Tag Sample Count])             AS taglengthsample,  " ,
                         "SUM(sd.Sample_count)                            AS samplecount " ,
                         "from dbo.GFBIO_RESEARCH_SAMPLE_DETAILS AS sd INNER JOIN " ,         
                         "dbo.GFBIO_SABLEBIO_TRIP_SET2 AS rt ON " ,
                         "sd.TRIP_ID = rt.TRIP_ID AND  sd.[SET] = rt.SET_NUMBER " ,
                         "where (sd.Year =", yr+1,") group by rt.SABLE_SET_TYPE",sep="") 
    countStRS2   <- GetSQLData(catchStRS2,"Sablefish")
   write.table( countStRS2 , file = paste(path,"results11_CountSamplesStRS.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

      lendat     <-   "exec procReport_Survey_LenMF"
      lendata    <-   GetSQLData(lendat,"Sablefish")
     write.table( lendata , file = paste(path,"results12_lengthMFData.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

      bio      <-   paste("select locality, depth, PropMales, PropFemales,MalesMnFkLen, FemalesMnFkLen, TaggedMnFkLen ",
                          "from gfbio_sable_bio_summary ",
                          "where depth is not null and year = ",yr,
                         " order by Locality,Depth", sep="")
      biosumm  <-   GetSQLData(bio,"Sablefish")
      write.table( biosumm , file = paste(path,"results13_BioSampleSummary.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

      bio.2      <-   paste("select locality, depth, PropMales, PropFemales, ",
                            "MalesMnFkLen, FemalesMnFkLen, TaggedMnFkLen ",
                            "from gfbio_sable_bio_summary ",
                            "where depth is not null and year = ",yr+1,
                            " order by Locality,Depth", sep="")
      biosumm.2  <-   GetSQLData(bio.2,"Sablefish")
      write.table(  biosumm.2 , file = paste(path,"results14_BioSampleSummary.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

      bio2       <-   paste("select locality, null as depth, PropMales, PropFemales,",
                            "MalesMnFkLen, FemalesMnFkLen, TaggedMnFkLen ",
                            "from  gfbio_sable_bio_summary ",
                            "where depth is null and   year = ",yr," order by Locality", sep="")
      biosumm2   <-   GetSQLData(bio2,"Sablefish")
      write.table( biosumm2 , file = paste(path,"results15_BioSampleSummaryInlet.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

      bio2       <-   paste("select locality, null as depth, PropMales, PropFemales,",
                            "MalesMnFkLen, FemalesMnFkLen, TaggedMnFkLen ",
                            "from  gfbio_sable_bio_summary ",
                            "where depth is null and   year = ",yr+1," order by Locality", sep="")
      biosumm2   <-   GetSQLData(bio2,"Sablefish")
      write.table( biosumm2 , file = paste(path,"results16_BioSampleSummaryInlet.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

     othfish      <-   paste(" select species_name, SUM(Sample_count) AS count   ",
                             " from dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH ",
                             " where (Year = ", yr, ") group by species_name, species ",
                             " ORDER BY species", sep="")
     otherfish    <-   GetSQLData(othfish,"Sablefish")
      write.table(otherfish , file = paste(path,"results17_OtheFishSamples.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")
     
     othfish2      <-   paste(" select species_name, SUM(Sample_count) AS count   ",
                             " from dbo.GFBIO_RESEARCH_SAMPLE_DETAILS_OTHER_FISH ",
                             " where (Year = ", yr+1, ") group by species_name, species ",
                             " ORDER BY species", sep="")
     otherfish2    <-   GetSQLData(othfish2,"Sablefish")
      write.table(otherfish2 , file = paste(path,"results18_OtheFishSamples.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   age         <-  paste("select Female_Yr_Total,Age from Report_Survey_GFBIO_Age_MF_Prop where ", 
                         "SetType='StRS' and f=1 and Year=",yr,sep="")
   agedat     <-  GetSQLData(age,"Sablefish")    # --  female age total and count of most aged text captions
   write.table( agedat , file = paste(path,"results19_SableAgesMF.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

   oldageF     <-  "exec procRReport_Survey_oldAgeFish 2"  # -- oldest female text caption
   oldageFem   <-  GetSQLData(oldageF,"Sablefish")
  write.table( oldageFem , file = paste(path,"results20_OldAgeFem.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")
   
   oldageM     <-  "exec procRReport_Survey_oldAgeFish 1"  # -- oldest male text caption
   oldageMale  <-  GetSQLData(oldageM,"Sablefish")
  write.table( oldageMale , file = paste(path,"results21_OldAgeMale.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

     whatTrap  <-  paste("select * from SEABIRD_ACCEL_byTrap where year =",yr," order by [set]",sep="")
     whatTraps <-  GetSQLData(whatTrap ,"Sablefish")  # in order to be able to comment on which traps the sensors were placed
     write.table(whatTraps , file = paste(path,"results22_TrapSeabirds.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

     seabrd    <-  "select * from SEABIRD_ReportLinePlot"
     seabird   <-  GetSQLData(seabrd ,"Sablefish") 
     write.table( seabird , file = paste(path,"results23_YearSeabirds.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")

    names      <-  paste(" select keyid, Association, year, Names from  dbo.ReportSurvey_Acknowlegdements where year=", yr, sep="")
    credits    <-  GetSQLData(names,"Sablefish")
     write.table(credits , file = paste(path,"results24_Credits.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")   
    
    names2    <-  paste(" select keyid, Association, year, Names from  dbo.ReportSurvey_Acknowlegdements where year=", yr+1, sep="")
    credits2  <-  GetSQLData(names2,"Sablefish")
     write.table(credits2 , file = paste(path,"results25_Credits.csv",sep=''),row.names=FALSE, na="",col.names=TRUE, sep=",")   



