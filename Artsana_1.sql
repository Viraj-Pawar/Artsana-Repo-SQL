USE [Artsana]
GO
/****** Object:  StoredProcedure [Test].[Artsana_1]    Script Date: 29-08-2022 18:33:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [Test].[Artsana_1]
	
AS
BEGIN

----* for test.active_list_Sequence START----
	DROP TABLE IF EXISTS test.active_list_Sequence
	SELECT *,
    ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS [Sequence] into test.active_list_Sequence
	FROM test.active_list AS t

----* for test.active_list_Sequence END----

----* for #active START----

	DROP TABLE IF EXISTS #active
	SELECT *INTO   #active FROM   
	(
              SELECT [Material Code]+'_'+bt AS [Key1],[Material Code],bt AS channel FROM   test.active_list
              WHERE  bt IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+[GT+MT] AS [Key1],[Material Code],[GT+MT] AS channel FROM   test.active_list
              WHERE  [GT+MT] IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+[HOS] AS [Key],[Material Code],hos AS channel FROM   test.active_list
              WHERE  hos IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+ka AS [Key1],[Material Code],ka AS channel FROM   test.active_list
              WHERE  ka IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+ebo AS [Key1],[Material Code],ebo AS channel FROM   test.active_list
              WHERE  ebo IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+rest AS [Key1],[Material Code],rest AS channel FROM   test.active_list
              WHERE  rest IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+ecom AS [Key1],[Material Code],ecom AS channel FROM   test.active_list
              WHERE  ecom IS NOT NULL 
	)x

----* for #active END----

----* for Test.Distributor_SKU_Wise_Data Start----

	DROP TABLE IF EXISTS Test.Distributor_SKU_Wise_Data
	SELECT * INTO Test.Distributor_SKU_Wise_Data FROM
	(
	SELECT Y.*,C.channel AS [Channel Active List]  FROM 
	(
	SELECT T.*,P.[RSM ID],Month(GETDATE()) AS [FC Month],Year(GETDATE()) AS [FC Year],([Mapped Code]+'_'+T.Channel) AS [Active Key]  FROM
	(
	SELECT a.*,(CASE WHEN b.[Mapped Code] is null THEN a.[Mat Code] ELSE b.[Mapped Code] END) AS [Mapped Code], dbo.CapitalizeFirstLetter(a.ASM2) AS X,
	(CASE WHEN [Channel Name L1] = 'BRAND-E-COM' THEN 'EC'
	WHEN [Channel Name L1] = 'BT' THEN 'SBT' WHEN [Channel Name L1] = 'EBO' THEN 'EBO' WHEN [Channel Name L1] = 'GT+MT' THEN 'SD'
	WHEN [Channel Name L1] = 'KA' THEN 'KA' WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ANKUSH KUMAR' THEN 'EX'
	WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ASM-EXPORT/INTI' THEN 'EX' WHEN [Channel Name L1] = 'Export + Others'
	AND ASM2 = 'ASM-HOSPITAL' THEN 'HO' END) AS Channel FROM Test.Sales_Data A
	LEFT JOIN test.[Mapping File] b ON a. [Mat Code] = b. [Material Code]
	)T
	LEFT JOIN (SELECT DISTINCT [ASM AREA],[RSM ID]  FROM Test.[RSM_ID] ) P ON P.[ASM AREA] = T.[USER ID]
	)Y
	LEFT JOIN #active c ON Y.[Active Key] = c.Key1
	)Z

----* for Test.Distributor_SKU_Wise_Data END----	

END