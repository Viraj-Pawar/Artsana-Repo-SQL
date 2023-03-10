


SELECT TOP 10 * FROM
(SELECT W.*, D.RSM_ID,Month(GETDATE()) AS FC_Month,Year(GETDATE()) AS FC_Year,
'RSM'+CAST(RSM_ID AS varchar)+(LEFT(W.Zone,1))+CAST(Month(GETDATE()) AS varchar) + CAST(Year(GETDATE()) AS varchar)+Channel AS Forecast_Number,
'RSM'+CAST(RSM_ID AS varchar)+(LEFT(W.Zone,1))+CAST(Month(GETDATE()) AS varchar) + CAST(Year(GETDATE()) AS varchar)+Channel+'_'+Mapped_Code AS [Key],
Mapped_Code+'_'+Channel AS Active_Key FROM
(SELECT A.*,(CASE WHEN B.[Mapped Code] is null Then [Mat Code] end) AS Mapped_Code,dbo.CapitalizeFirstLetter(a.ASM2) AS X,C.Channel FROM Test.Sales_Data A
LEFT JOIN Test.[Mapping File] B ON A.[Mat Code] = B.[Material Code]
LEFT JOIN Test.Channel C ON A.[Channel Name L1] = C.[Channel Name L1])W
LEFT JOIN Test.[RSM ID] D ON W.[Channel] = D.Zone ) X


-------------------------------------------------NEW CODE-------------------------------------
	DROP TABLE IF EXISTS #active, #Realigned_RSM
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


	DROP TABLE IF EXISTS #Realigned_RSM
	SELECT ( CASE
				WHEN zone = 'EX' THEN 'EX'
				WHEN zone = 'EC' THEN 'EC'
				WHEN rsm IS NULL THEN zone + '_' + region
				ELSE zone + '_' + rsm+LOWER(Region)
				END ) AS k1, * into #Realigned_RSM
	FROM   test.[rsm id] 



	 ---791240
	SELECT TOP 10 * FROM
	-- SELECT COUNT(*) FROM 
	(
	SELECT T.*,Month(GETDATE()) AS [FC Month],Year(GETDATE()) AS [FC Year],([Mapped Code]+'_'+Channel) AS [Active Key]  FROM
	(
	SELECT a.*,(CASE WHEN b.[Mapped Code] is null THEN a.[Mat Code] ELSE b.[Mapped Code] END) AS [Mapped Code], dbo.CapitalizeFirstLetter(a.ASM2) AS X,(CASE WHEN [Channel Name L1] = 'BRAND-E-COM' THEN 'EC'
	WHEN [Channel Name L1] = 'BT' THEN 'SBT' WHEN [Channel Name L1] = 'EBO' THEN 'EBO' WHEN [Channel Name L1] = 'GT+MT' THEN 'SD'
	WHEN [Channel Name L1] = 'KA' THEN 'KA' WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ANKUSH KUMAR' THEN 'EX'
	WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ASM-EXPORT/INTI' THEN 'EX' WHEN [Channel Name L1] = 'Export + Others'
	AND ASM2 = 'ASM-HOSPITAL' THEN 'HO' END) AS Channel FROM Test.Sales_Data A
	LEFT JOIN test.[Mapping File] b ON a. [Mat Code] = b. [Material Code]
	)T
	--LEFT JOIN #Realigned_RSM P ON P.k1 = CASE WHEN Channel = 'EX' THEN 'EX' WHEN Channel = 'EC' THEN 'EC'
	) Z
