


-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-10-13>
-- Description:	<Load priceSurveyProdCategory>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_priceSurveyProdCategory]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
SELECT DISTINCT name ,REPLACE(value,'''','') as value,SUBSTRING(name,0,CHARINDEX('_',LTRIM(RTRIM(name)))) Domain
				,SUBSTRING(name,CHARINDEX('_',LTRIM(RTRIM(name)))+1,CHARINDEX('_' ,LTRIM(RTRIM(name)))-1)Principal
				,SUBSTRING(name, P2.Pos + 1, P3.Pos - P2.Pos - 1) as PLine ,SUBSTRING(name, P3.Pos + 1, P4.Pos - P3.Pos - 1) AS PackSize 
						INTO #PSCategory
	FROM pdFData
	CROSS APPLY (SELECT (CHARINDEX('_', name))) AS P1(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P1.Pos+1))) AS P2(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P2.Pos+1))) AS P3(Pos)
	cross apply (SELECT (CHARINDEX('_', name, P3.Pos+1))) AS P4(Pos)
	WHERE name like '%_select%'
	AND SUBSTRING(name,0,CHARINDEX('_',LTRIM(RTRIM(name)))) <> 'Housebrand'
	AND value <> 'new product'
	AND subject ='price survey'
	AND value not in ('.','.00','00.00','0000','0.','000','0.0','00','0.00','0','','off','[ ]')
	

	SELECT *, LEFT(value, CHARINDEX(PackSize, value) - 1) AS Category INTO #Category
	FROM #PSCategory 
	
  --///////////////////////////////////////////////////////////////////////
	SELECT DISTINCT taskInstanceuuid, SUBSTRING(name,0,CHARINDEX('_',LTRIM(RTRIM(name)))) AS Domain
				   ,SUBSTRING(name,0,CHARINDEX('_',LTRIM(RTRIM(name)))) AS Brand
				   ,SUBSTRING(name,P1.Pos+1,(P2.Pos-P1.Pos-1)) AS Principal
				   ,SUBSTRING(name, P2.Pos + 1, P3.Pos - P2.Pos - 1) AS PLine
				   ,SUBSTRING(name, P3.Pos + 1, P4.Pos - P3.Pos - 1) AS PackSize
				   ,CONVERT(VARCHAR (40),'') AS Category,name ,value
				   INTO #Brand
	FROM pdFData
	CROSS APPLY (SELECT (CHARINDEX('_', name))) AS P1(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P1.Pos+1))) AS P2(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P2.Pos+1))) AS P3(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P3.Pos+1))) AS P4(Pos)
	WHERE (name   like '%_price%' OR name like '%_Promo' )
	AND value <> 'new product'
	AND subject ='price survey'
	AND value not in ('.','.00','00.00','0000','0.','000','0.0','00','0.00','0','','off','[ ]')
	ORDER BY Brand
	
	SELECT DISTINCT b.domain,b.pline,b.ItemLvL1,b.ItemLvL2 INTO  #AS1Brand --the opposite of this will give you the competitor
	FROM #Brand a
	INNER JOIN Warehouse.Dimension.Products b
	ON a.PLine = b.PLine
	AND a.Domain = b.Domain 
	WHERE IsCurrent = 'y'
	AND ItemLvL1 <>''

	UPDATE  #Brand
	SET Brand = b.ItemLvL1,
	Category = b.ItemLvL2
	FROM #Brand a
	INNER JOIN #AS1Brand b
	ON a.PLine = b.PLine
	AND a.domain =b.domain 
	
	UPDATE  #Brand
	SET Category = b.Category
	FROM #Brand a
	INNER JOIN #Category b
	ON a.PLine = b.PLine
	AND a.Principal = b.Principal

	SELECT DISTINCT Domain,Principal,LOWER(Brand) brand,LOWER(Category) category,pLine,packSize,name as Item 
	INTO #pCategoryItem
	FROM #Brand

	SELECT  DISTINCT Domain,principal, brand, category,pLine,packSize 
	INTO #priceSurveyProdCategory
	FROM  #pCategoryItem 

	MERGE [Warehouse_BlueFileData].[Dimension].[priceSurveyProdCategory] AS Target
	USING #priceSurveyProdCategory	AS Source
	ON Source.Domain = Target.Domain
	AND Source.principal = Target.principal
	AND Source.brand = Target.brand
	AND Source.category = Target.category
	AND Source.pLine = Target.pLine
	AND Source.packSize = Target.packSize
	WHEN NOT MATCHED BY Target THEN
    INSERT (Domain,principal, brand, category,pLine,packSize ) 
    VALUES (Source.Domain,Source.principal,Source.brand, Source.category,Source.pLine,Source.packSize );
END
