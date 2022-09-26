USE [Artsana]
GO
/****** Object:  StoredProcedure [Test].[Artsana_1]    Script Date: 20-09-2022 17:26:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [Test].[Artsana_1]
----EXEC  [Test].[Artsana_1]
AS
BEGIN

----* for Artsana.test.active_list_Sequence START----
	DROP TABLE IF EXISTS Artsana.test.active_list_Sequence
	SELECT 
		*, ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS [Sequence] 
		INTO Artsana.test.active_list_Sequence
	FROM Artsana.test.active_list AS t

----* for test.active_list_Sequence END----

----* for #active START----

	DROP TABLE IF EXISTS #active
	SELECT *INTO   #active FROM   
	(
              SELECT [Material Code]+'_'+bt AS [Key1],[Material Code],bt AS channel FROM   Artsana.test.active_list
              WHERE  bt IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+[GT+MT] AS [Key1],[Material Code],[GT+MT] AS channel FROM   Artsana.test.active_list
              WHERE  [GT+MT] IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+[HOS] AS [Key],[Material Code],hos AS channel FROM   Artsana.test.active_list
              WHERE  hos IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+ka AS [Key1],[Material Code],ka AS channel FROM   Artsana.test.active_list
              WHERE  ka IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+ebo AS [Key1],[Material Code],ebo AS channel FROM   Artsana.test.active_list
              WHERE  ebo IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+rest AS [Key1],[Material Code],rest AS channel FROM   Artsana.test.active_list
              WHERE  rest IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+ecom AS [Key1],[Material Code],ecom AS channel FROM   Artsana.test.active_list
              WHERE  ecom IS NOT NULL 
	)x

----* for #active END----

----* for Test.Distributor_SKU_Wise_Data Start----

	DROP TABLE IF EXISTS Artsana.Test.Distributor_SKU_Wise_Data
	SELECT * INTO Artsana.Test.Distributor_SKU_Wise_Data FROM
	(
		SELECT Y.*,C.channel AS [Channel Active List],'RSM'+CAST([RSM ID] AS Varchar) +(CASE WHEN Y.Channel = 'KA' THEN '' ELSE LEFT(Zone,1) END)
		+Cast([FC Month] AS varchar)+cast([FC Year] as varchar)+Y.Channel AS [Forecast Number],
		'RSM'+CAST([RSM ID] AS varchar)+LEFT(Zone,1)+cast([FC Month]as varchar)+ cast([FC Year]AS varchar)+Y.Channel+'_'+cast([Mapped Code] as varchar) AS [Key] FROM 
		(
			SELECT T.*,P.[RSM ID],Month(GETDATE()) AS [FC Month],Year(GETDATE()) AS [FC Year],([Mapped Code]+'_'+T.Channel) AS [Active Key]  FROM
			(
				SELECT a.*,(CASE WHEN b.[Mapped Code] is null THEN a.[Mat Code] ELSE b.[Mapped Code] END) AS [Mapped Code], dbo.CapitalizeFirstLetter(a.ASM2) AS X,
				(CASE WHEN [Channel Name L1] = 'BRAND-E-COM' THEN 'EC'
				WHEN [Channel Name L1] = 'BT' THEN 'SBT' WHEN [Channel Name L1] = 'EBO' THEN 'EBO' WHEN [Channel Name L1] = 'GT+MT' THEN 'SD'
				WHEN [Channel Name L1] = 'KA' THEN 'KA' WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ANKUSH KUMAR' THEN 'EX'
				WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ASM-EXPORT/INTI' THEN 'EX' WHEN [Channel Name L1] = 'Export + Others'
				AND ASM2 = 'ASM-HOSPITAL' THEN 'HO' END) AS Channel FROM Artsana.Test.Sales_Data A
				LEFT JOIN Artsana.test.[Mapping File] b ON a. [Mat Code] = b. [Material Code]
			)T
			LEFT JOIN (SELECT DISTINCT [ASM AREA],[RSM ID]  FROM Artsana.Test.[RSM_ID] ) P ON P.[ASM AREA] = T.[USER ID]
		)Y
		LEFT JOIN #active c ON Y.[Active Key] = c.Key1
	)Z

----* for Test.Distributor_SKU_Wise_Data END----	

----* for Base File Start----	
	DROP TABLE IF EXISTS Test.Base_File
	SELECT  [key]+'_'+Cast([Month] as varchar)+'_'+cast([Year] as varchar) AS [Key2],[Year],[Month],
			[Cust Code],[Customer Name],[Mat Code],Qty,[Value(in Lakhs)],[Mapped Code] AS [mapping Code],X,Channel,
			[RSM ID],[FC Month],[FC Year],[Forecast Number],[Key],[Channel Active List] AS [Active list] 
		INTO Artsana.Test.Base_File
	FROM [Artsana].[Test].[Distributor_SKU_Wise_Data]
	WHERE [Year] >= 2018

----* for Base File END----	

----* for mapping file_extracolumn START----	

------DROP TABLE IF EXISTS test.[mapping file_extracolumn]
------SELECT a.*,b.[sfa category] AS Subgroup,line1,line2,line3,line4
------INTO   Artsana.test.[mapping file_extracolumn]
------FROM   Artsana.test.[mapping file] a
------       LEFT JOIN (SELECT DISTINCT [Mapped Code],[sfa category],line1,line2,line3,line4
------                  FROM   Artsana.test.distributor_sku_wise_data) b
------              ON a.[Mapped Code] = b.[Mapped Code]

DROP TABLE IF EXISTS test.[mapping file_extracolumn]
	select *  into test.[mapping file_extracolumn] from 
		(SELECT * ,ROW_NUMBER() OVER(partition by [Mapped Code] order by [Mapped Code]) AS RN from 
			(SELECT a.*,b.[sfa category] AS Subgroup,line1,line2,line3,line4
			FROM   Artsana.test.[mapping file] a
				LEFT JOIN (SELECT DISTINCT [Mapped Code],[sfa category],line1,line2,line3,line4
							FROM   Artsana.test.distributor_sku_wise_data) b
			ON a.[Mapped Code] = b.[Mapped Code]) t1) t
		WHERE  RN = 1

----* for mapping file_extracolumn END----	

----* for Artsana_Data details_base file-all channels-Sep START

DROP TABLE IF EXISTS Artsana.Test.Artsana_Data_details_base_file_all_channels
SELECT * into Artsana.Test.Artsana_Data_details_base_file_all_channels FROM
--SELECT COUNT(*) FROM
(
SELECT [Key],[Year],[Month],A.[Mapped Code],
(CASE WHEN B.[Material Description] is null THEN A.[Material Description] ELSE B.[Material Description] END) AS Description,
(CASE WHEN B.[Category1] is null THEN A.Category ELSE B.Category1 END) AS Category,
(CASE WHEN B.[Category] is null THEN A.Category1 ELSE B.Category END) AS Category1,
(CASE WHEN B.[Material Status] is null THEN 'Inactive' ELSE B.[Material Status] END) AS [Material Status],
(CASE WHEN B.[Purchasing Source (Imported/ Domestic)] is null THEN 'Inactive' ELSE B.[Purchasing Source (Imported/ Domestic)] END) AS [Domestic/Import],
Channel,[RSM ID],[FC Month],[FC Year],[Forecast Number],Zone AS Region,A.[NSM ],[RSM/ZSM ],A.[USER ID] AS [ABC (Qty)],
(CASE WHEN Channel = 'KA' THEN [USER ID] ELSE ASM2 END) AS [RSM],Qty,[Value(in Lakhs)],
(CASE WHEN C.Subgroup  is null OR C.Subgroup  = '0' THEN A.[SFA Category] ELSE C.Subgroup  END) AS Subgroup,
(CASE WHEN C.line1 is null OR C.line1 = '0' THEN A.Line1 ELSE C.line1 END) AS Line1,
(CASE WHEN C.line2 is null OR C.line2 = '0' THEN A.Line2 ELSE C.line2 END) AS Line2,
(CASE WHEN C.line3 is null OR C.line3 = '0' THEN A.Line3 ELSE C.line3 END) AS Line3,
(CASE WHEN C.line4 is null OR C.line4 = '0' THEN A.Line4 ELSE C.line4 END) AS Line4,
([Value(in Lakhs)]/100000) AS [Value],[Channel Active List] as [Active Channel],[Active Key],ShPt,City,State
FROM Artsana.Test.Distributor_SKU_Wise_Data A
LEFT JOIN Artsana.Test.active_list_Sequence B ON A.[Mapped Code] = B.[Material Code]
LEFT JOIN Artsana.Test.[mapping file_extracolumn] C ON A.[Mapped Code] = C.[Mapped Code]
) T 

----* for Artsana_Data details_base file-all channels-Sep END

----* for Tab: All-exclude KA to be pasted ---*[Value(in Lakhs)]* START

DROP TABLE IF EXISTS #Temp_without_KA,#Temp_with_KA,All_exclude_KA_QTY,All_exclude_KA_Value
SELECT  *,CAST([Month] AS VARCHAR)+CAST([Year] AS VARCHAR) AS [date] into #Temp_without_KA FROM Artsana.Test.Artsana_Data_details_base_file_all_channels where Channel != 'KA'
SELECT  *,CAST([Month] AS VARCHAR)+CAST([Year] AS VARCHAR) AS [date] into #Temp_with_KA FROM Artsana.Test.Artsana_Data_details_base_file_all_channels where Channel = 'KA'

DECLARE @Col VARCHAR(MAX)
DECLARE @SQL NVARCHAR(MAX)

SET @Col = (SELECT STRING_AGG([date],',') FROM
(SELECT DISTINCT [date] FROM #Temp_without_KA )t)


SET @SQL = 
'SELECT [Forecast Number],[FC Month],[FC Year],Region,Channel,
[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
[Domestic/Import],[ABC (Qty)],Category1,' + @Col + ' into All_exclude_KA_Value
FROM 
(SELECT [Forecast Number],[FC Month],[FC Year],Region,Channel,
[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
[Domestic/Import],[ABC (Qty)],Category1,[Value(in Lakhs)],[date]
FROM #Temp_without_KA
) as Source_table
PIVOT
(SUM([Value(in Lakhs)]) for [date] in (' +@Col +')
) AS Pivot_table'

EXECUTE(@SQL)

----* for Tab: All-exclude KA to be pasted ---*[Value(in Lakhs)]* END

----* for Tab: All-exclude KA to be pasted ---*[Qty]* START

DECLARE @Col1 VARCHAR(MAX)
DECLARE @SQL1 NVARCHAR(MAX)

SET @Col1 = (SELECT STRING_AGG([date],',') FROM
(SELECT DISTINCT [date] FROM #Temp_without_KA )t)


SET @SQL1 = 
'SELECT [Forecast Number],[FC Month],[FC Year],Region,Channel,
[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
[Domestic/Import],[ABC (Qty)],Category1,' + @Col1 + ' into All_exclude_KA_QTY
FROM 
(SELECT [Forecast Number],[FC Month],[FC Year],Region,Channel,
[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
[Domestic/Import],[ABC (Qty)],Category1,[Qty],[date]
FROM #Temp_without_KA
) as Source_table
PIVOT
(SUM([Qty]) for [date] in (' +@Col1 +')
) AS Pivot_table'

EXECUTE(@SQL1) 

----* for Tab: All-exclude KA to be pasted ---*[Qty]* END
----* KA


DECLARE @Col2 VARCHAR(MAX)
DECLARE @SQL2 NVARCHAR(MAX)

SET @Col2 = (SELECT STRING_AGG([date],',') FROM
(SELECT DISTINCT [date] FROM #Temp_with_KA )t)


SET @SQL2 = 
'SELECT [Forecast Number],[FC Month],[FC Year],Region,Channel,
[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
[Domestic/Import],[ABC (Qty)],Category1,' + @Col2 + ' into All_with_KA_QTY 
FROM 
(SELECT [Forecast Number],[FC Month],[FC Year],Region,Channel,
[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
[Domestic/Import],[ABC (Qty)],Category1,[Qty],[date]
FROM #Temp_with_KA
) as Source_table
PIVOT
(SUM([Qty]) for [date] in (' +@Col2 +')
) AS Pivot_table'

EXECUTE(@SQL2) 



END





