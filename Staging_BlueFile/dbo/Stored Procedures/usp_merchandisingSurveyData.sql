
-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-10-02>
-- Description:	<Load usp_merchandisingSurveyData>
-- Merchandising Survey processed where value <> ('','0','[ ]','Off') (productPlacement,shelfFacings,[2ndDisplayType])
-- ==================================================
CREATE PROCEDURE [dbo].[usp_merchandisingSurveyData]
AS
BEGIN
	SET NOCOUNT ON;
	TRUNCATE TABLE st_merchandisingSurvey
--///////////////////////////////////////////////////////////////////////
	SELECT taskInstanceUuid,uuid AS pdFUuid,name, SUBSTRING (name,1,P1.Pos-1) AS Item,SUBSTRING (name,P1.Pos+1,P2.Pos-P1.Pos-1) AS pLine,
	SUBSTRING (name,P2.Pos+1,P3.Pos-P2.Pos-1) AS packSize,SUBSTRING(name, P3.Pos + 1, LEN(name)) AS shelf, value 
	INTO #mSurvey1
	FROM pdFData
	CROSS APPLY (SELECT (CHARINDEX('_', name))) AS P1(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P1.Pos+1))) AS P2(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P2.Pos+1))) AS P3(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P3.Pos+1))) AS P4(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P4.Pos+1))) AS P5(Pos)
	WHERE  subject = 'merchandising survey'
    AND value not in ('','0','[ ]','Off')
	AND (name   like '%ShelfFacings' OR name like '%ProductPlacement' OR name like '%_2ndDisplayType' ) 

---/////////////////////////////////////////////////////////////////////////////////////////////////////////////
--Part 2 transpose productPlacement,shelfFacings,[2ndDisplayType]
	SELECT taskInstanceUuid,pdfUuid,item,pLine,packSize, productPlacement,shelfFacings,[2ndDisplayType] INTO #mSurvey2
	FROM (
		SELECT taskInstanceUuid,pdfUuid,Item,pLine,packSize
			 , CASE 
			   WHEN shelf = 'ProductPlacement' THEN 
			  	   REPLACE(REPLACE(value,'[',''),']','')
			   ELSE
				   ''
			   END AS ProductPlacement 
			 , CASE 
			   WHEN shelf = 'ShelfFacings' THEN 
					value 
			   ELSE
				   '0'
			   END AS ShelfFacings 
			 , CASE 
			   WHEN shelf = '2ndDisplayType' THEN 
			     REPLACE(REPLACE(value,'[',''),']','')
			   ELSE
				   ''
			   END AS [2ndDisplayType]
		FROM #mSurvey1
		) AS T 

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	SELECT  taskInstanceUuid,pdFUuid, Item,pLine,packSize,MAX(ProductPlacement) AS ProductPlacement,MAX(ShelfFacings) AS ShelfFacings,MAX([2ndDisplayType]) AS [2ndDisplayType]
	INTO  #mSurvey3
	FROM #mSurvey2 
	GROUP BY taskInstanceUuid,pdFUuid,Item,pLine,packSize

 --//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 --insert values from #pS3 and defaults taskTracker values 
	 INSERT INTO  st_merchandisingSurvey
	 SELECT  '' AS Domain, taskInstanceUuid,pdFUuid,-1 AS KeyCustomer,'' AS appointmentTypeUuid,-1 AS keyscheduleType,-1 AS keyappointmentDate
			,-1 AS keystartTime,-1 AS keyendTime,'' AS companyUserUuid,'' AS customerLocationUuid,'' AS customerAccountUuid,'' AS tradeChannelUuid,
			'' AS principalUuid,'' AS serviceProviderUuid	,'' AS salesAgencyCostCentreUuid,-1 AS keytaskStatus,-1 AS keycompletedDate,-1 AS keycompletedTime,
			''AS taskTypeUuid, -1 AS KeyProduct,item, pLine,packSize,productPlacement,shelfFacings,[2ndDisplayType]
	FROM #mSurvey3
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--update keys and uuid's with taskTracker values
	UPDATE st_merchandisingSurvey
	SET domain = b.domain,
		keyCustomer = b.keyCustomer,
		appointmentTypeUuid = b.appointmentTypeUuid,
		keyscheduleType = b.keyscheduleType,
		keyappointmentDate = b.keyappointmentDate,
		keystartTime = b.keystartTime,
		keyendTime = b.keyendTime,
		companyUserUuid = b.companyUserUuid,
		customerLocationUuid = b.customerLocationUuid,
		customerAccountUuid = b.customerAccountUuid,
		tradeChannelUuid = b.tradeChannelUuid,
		principalUuid = b.principalUuid,
		serviceProviderUuid = b.serviceProviderUuid,
		salesAgencyCostCentreUuid = b.salesAgencyCostCentreUuid, 
		keytaskStatus = b.keytaskStatus ,
		keycompletedDate = b.keycompletedDate,
		keycompletedTime = b.keycompletedTime,
		taskTypeUuid = b.taskTypeUuid
	FROM st_merchandisingSurvey a 
	INNER JOIN Warehouse_BlueFileData.Fact.taskTracker b
	ON a.taskInstanceUuid = b.taskInstanceUuid

--///////////////////////////////////////////////////////////
-----Update Product Key
	UPDATE st_merchandisingSurvey
	SET keyProduct = c.KeyProduct
	FROM st_merchandisingSurvey a
	INNER JOIN (SELECT DISTINCT Domain,AS1PrincipalCode FROM [dbo].[umt_BF_PrincipalDomain]) b
	ON a.domain =b.domain
	INNER JOIN Warehouse.Dimension.Products c
	ON a.Domain = c.Domain
	AND b.AS1PrincipalCode = c.Principal
	AND a.Item = c.Item
	AND c.IsCurrent = 'y'
--//////////////////////////////////////////////////////////////
---Update Product Key where item is '-1'
	UPDATE st_merchandisingSurvey
	SET keyProduct = c.KeyProduct
	FROM st_merchandisingSurvey a
	INNER JOIN (SELECT DISTINCT Domain,AS1PrincipalCode FROM [dbo].[umt_BF_PrincipalDomain]) b
	ON a.domain =b.domain
	INNER JOIN Warehouse.Dimension.Products c
	ON a.Domain = c.Domain
	AND b.AS1PrincipalCode = c.Principal
	AND  c.Item = '-1'
	AND c.IsCurrent = 'y'
	WHERE a.keyProduct = '-1'

--==================================================================
--Overwrite existing merchandisingSurvey records
--==================================================================
	DELETE [Warehouse_BlueFileData].[Fact].[merchandisingSurvey]
	FROM [Warehouse_BlueFileData].[Fact].[merchandisingSurvey] a
	INNER JOIN st_merchandisingSurvey b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	AND  a.Domain = b.Domain
	--WHERE a.KeytaskStatus <> 2
--===================================================================
--Insert new records into Fact.tasktracker
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Fact].[merchandisingSurvey]
	(Domain,taskInstanceUuid,pdFUuid,keyCustomer,appointmentTypeUuid,keyscheduleType,keyappointmentDate,keystartTime,keyendTime,companyUserUuid,customerLocationUuid
      ,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,keytaskStatus,keycompletedDate,keycompletedTime,taskTypeUuid
      ,keyProduct,Item,pLine,packSize,productPlacement,shelfFacings,[2ndDisplayType])
	  
	  SELECT Domain,taskInstanceUuid,pdFUuid,keyCustomer,appointmentTypeUuid,keyscheduleType,keyappointmentDate,keystartTime,keyendTime,companyUserUuid,customerLocationUuid
			,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,keytaskStatus,keycompletedDate,keycompletedTime,taskTypeUuid
			,keyProduct,Item,pLine,packSize,productPlacement,shelfFacings,[2ndDisplayType]
	 FROM st_merchandisingSurvey
END
