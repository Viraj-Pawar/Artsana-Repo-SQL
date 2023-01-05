USE [Artsana]
GO
/****** Object:  StoredProcedure [Test].[Artsana_1_Model_Input]    Script Date: 05-01-2023 15:19:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----RAW FILES USED
--1) Artsana.test.Active_List_raw
--2) Artsana.test.sales_data
--3) Artsana.Test.[RSM_ID]
--4) Artsana.Test.ASP_Raw
--5) Artsana.test.[Mapping File] 


ALTER PROCEDURE [Test].[Artsana_1_Model_Input]
----EXEC  [Test].[Artsana_1_Model_Input]
AS
BEGIN

----* for making Distinct Artsana.test.active_list START----
DROP TABLE IF EXISts  Artsana.Test.Active_List
SELECT DISTINCT * into Artsana.Test.Active_List FROM Artsana.Test.Active_List_raw

----* for making Distinct Artsana.test.active_list END----


----* for Artsana.test.active_list_Sequence START----
	DROP TABLE IF EXISTS Artsana.test.active_list_Sequence
	SELECT 
		*, ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS [Sequence] 
		INTO Artsana.test.active_list_Sequence
	FROM Artsana.test.active_list AS t

----* for test.active_list_Sequence END----


----* for Active_Long START----

	DROP TABLE IF EXISTS Artsana.Test.Active_Long
	SELECT * INTO   Artsana.Test.Active_Long FROM   
	(
              SELECT [Material Code]+'_'+SBT AS [Key1],*,SBT AS channel FROM   Artsana.test.active_list
              WHERE  SBT IS NOT NULL
              UNION all
              SELECT [Material Code]+'_'+SD AS [Key1],*,SD AS channel FROM   Artsana.test.active_list
              WHERE  SD IS NOT NULL
              UNION all
              SELECT [Material Code]+'_'+HO AS [Key],*,HO AS channel FROM   Artsana.test.active_list
              WHERE  HO IS NOT NULL
              UNION all
              SELECT [Material Code]+'_'+KA AS [Key1],*,KA AS channel FROM   Artsana.test.active_list
              WHERE  KA IS NOT NULL
              UNION all
              SELECT [Material Code]+'_'+EBO AS [Key1],*,EBO AS channel FROM   Artsana.test.active_list
              WHERE  EBO IS NOT NULL
              UNION all
              SELECT [Material Code]+'_'+EX AS [Key1],*,EX AS channel FROM   Artsana.test.active_list
              WHERE  EX IS NOT NULL
              UNION all
              SELECT [Material Code]+'_'+EC AS [Key1],*,EC AS channel FROM   Artsana.test.active_list
              WHERE  EC IS NOT NULL 
	)x


----* for Converting -ve values to zero in sales data Start----

UPDATE Artsana.test.sales_data
SET Qty = 0.00, [Value(in Lakhs)]= 0.00
WHERE Qty < 0 OR [Value(in Lakhs)] < 0.00;

UPDATE Artsana.test.sales_data
SET  [Value(in Lakhs)]= 0.00
WHERE Qty = 0 

UPDATE Artsana.test.sales_data
SET  Qty= 0.00
WHERE [Value(in Lakhs)] = 0 

----* for Converting -ve values to zero in sales data End----

----* for Normalizing EBO and HO is Sales file END----
UPDATE Artsana.test.sales_data
SET [USER ID] = 'EBO'
WHERE [USER ID] like '%EBO%'

UPDATE Artsana.test.sales_data
SET [USER ID] = 'HO'
WHERE [USER ID] like '%HO%'

UPDATE Artsana.test.sales_data
SET Category = null
WHERE Category = '#N/A'

----* for Normalizing EBO and HO is Sales file END----

----* for Test.Distributor_SKU_Wise_Data Start----

	DROP TABLE IF EXISTS Artsana.Test.Distributor_SKU_Wise_Data
	SELECT * INTO Artsana.Test.Distributor_SKU_Wise_Data FROM
	(
		SELECT Y.*,C.channel AS [Channel Active List],'RSM'+CAST([RSM ID] AS Varchar) +(CASE WHEN Y.Channel = 'KA' THEN '' ELSE LEFT([New_Zone],1) END)
		+Cast([FC Month] AS varchar)+cast([FC Year] as varchar)+Y.Channel AS [Forecast Number],
		'RSM'+CAST([RSM ID] AS varchar)+(CASE WHEN Y.Channel = 'KA' THEN '' ELSE LEFT([New_Zone],1) END)
		+cast([FC Month]as varchar)+ cast([FC Year]AS varchar)+Y.Channel+'_'+cast([Mapping_Code] as varchar) AS [Key] FROM 
		(
			SELECT T.*,P.[RSM ID],Month(GETDATE()) AS [FC Month],Year(GETDATE()) AS [FC Year],(t.[Mapping_Code]+'_'+T.Channel) AS [Active Key]  FROM
			(
				SELECT a.*,(CASE WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ASM-EXPORT/INTI' THEN 'Export' ELSE [Zone] end) as [New_Zone]
				,(CASE WHEN b.[Mapped Code] is null THEN a.[Mat Code] ELSE b.[Mapped Code] END) AS [Mapping_Code], Artsana.dbo.CapitalizeFirstLetter(a.ASM2) AS X,
				(CASE WHEN [Channel Name L1] = 'BRAND-E-COM' THEN 'EC'
				WHEN [Channel Name L1] = 'BT' THEN 'SBT' 
				WHEN [Channel Name L1] = 'EBO' THEN 'EBO' 
				WHEN [Channel Name L1] = 'GT+MT' THEN 'SD'
				WHEN [Channel Name L1] = 'KA' THEN 'KA' 
				WHEN [Channel Name L1] = 'SA' THEN 'KA' WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ANKUSH KUMAR' THEN 'HO'
				WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ASM-EXPORT/INTI' THEN 'EX' WHEN [Channel Name L1] = 'Export + Others'
				AND ASM2 = 'ASM-HOSPITAL' THEN 'HO'   END) AS Channel FROM Artsana.Test.Sales_Data A 
				LEFT JOIN Artsana.test.[Mapping File] b ON a. [Mat Code] = b. [Material Code] where a.Category is not null
			)T  
	
			LEFT JOIN (SELECT DISTINCT [ASM AREA],[RSM ID],[Zone]  FROM Artsana.Test.[RSM_ID] ) P ON P.[ASM AREA]+P.[Zone]  =  T.[USER ID]+T.[New_Zone]
			
			--CASE WHEN P.[ASM AREA] = 'EBO' OR P.[ASM AREA] = 'HO' THEN P.[ASM AREA]+P.[Zone] ELSE P.[ASM AREA] END= 
			--CASE WHEN T.[USER ID] = 'EBO' OR T.[USER ID] = 'HO' THEN T.[USER ID]+T.[New_Zone] ELSE T.[USER ID] END
		)Y
		LEFT JOIN (SELECT Distinct Key1 , channel from Artsana.Test.Active_Long) c ON Y.[Active Key] = c.Key1
	)Z

----* for Test.Distributor_SKU_Wise_Data END----	        

----* for Base File Start----	
	DROP TABLE IF EXISTS Artsana.Test.Base_File
	SELECT  [key]+'_'+Cast([Month] as varchar)+'_'+cast([Year] as varchar) AS [Key2],[Year],[Month],
			[Cust Code],[Customer Name],[Mat Code],Qty,[Value(in Lakhs)],[Mapping_Code] AS [mapping Code],X,Channel,
			[RSM ID],[FC Month],[FC Year],[Forecast Number],[Key],[Channel Active List] AS [Active list] 
		INTO Artsana.Test.Base_File
	FROM [Artsana].[Test].[Distributor_SKU_Wise_Data]
	WHERE [Year] >= 2018

----* for Base File END----	

----* for Artsana.test.ASP_long from wide Start

DROP TABLE IF EXISTS Artsana.Test.[ASP_long]
SELECT [Material Code],Channel, ASP into Artsana.test.ASP_long FROM  Artsana.Test.ASP_Raw
UNPIVOT
(ASP FOR Channel IN (EBO,KA,SBT,SD,[HO & EX],EC)
) a

----* for Artsana.test.ASP_long from wide Start

----* for Forecasting_Pivot_base_file Start----	
	
	DROP TABLE IF EXISTS Artsana.Test.Forecasting_Pivot_base_file
	
SELECT *  Into Artsana.Test.Forecasting_Pivot_base_file FROM 
(
	SELECT [Key],[mapping Code],Asp, [Year], [Month],'Active' as [Active list],sum(Qty ) as Qty, Sum([Value(in Lakhs)]) as [Value(in Lakhs)],
	CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) as [Date]
	FROM 
	(
		(SELECT [Key], [Year], [Month], Qty,[Value(in Lakhs)],[mapping Code],[Active list] FROM Artsana.Test.Base_File 
		where [Active list] is not null
		)b
	LEFT JOIN Artsana.Test.ASP_long s ON 
	b.[mapping Code]+(case when b.[Active list] = 'HO' Or b.[Active list] = 'EX' Then 'EX' ELSE b.[Active list] end) =
	s.[Material Code] + (case when s.Channel = 'HO & EX'  Then 'EX' ELSE s.Channel end)
	)
	GROUP BY [Key], [Year], [Month],[Active list], [mapping Code],ASP
)d


----* for Forecasting_Pivot_base_file End----	

END