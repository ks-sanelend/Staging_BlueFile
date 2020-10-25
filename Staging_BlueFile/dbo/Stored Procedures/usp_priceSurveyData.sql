

-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Load usp_priceSurveyData>
-- Price Survey processed where value <> 0 or blank (unitprice, shrinkprice and bulkbuyunits)
-- and BulkBuy and Promo have been selected
-- ==================================================
CREATE PROCEDURE [dbo].[usp_priceSurveyData]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_priceSurvey
	SELECT taskInstanceUuid,uuid AS pdFUuid,name AS Item,SUBSTRING(name, P4.Pos + 1, LEN(name)) AS UOM, value 
	INTO #pS1
	FROM pdFData
	CROSS APPLY (SELECT (CHARINDEX('_', name))) AS P1(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P1.Pos+1))) AS P2(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P2.Pos+1))) AS P3(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P3.Pos+1))) AS P4(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P4.Pos+1))) AS P5(Pos)
	WHERE (name   like '%_price%' OR name like '%_Promo') 
	AND value <> 'new product'
	AND subject ='price survey'
	AND value not in ('.','.00','00.00','0000','0.','000','0.0','00','0.00','0','','off')
---/////////////////////////////////////////////////////////////////////////////////////////////////////////////
--Part 2 transpose values to UOM
	SELECT taskInstanceUuid,pdfUuid,item, unitPrice,shrinkPrice,promo into #pS2
	FROM (
		SELECT taskInstanceUuid,pdfUuid,Item
			 , CASE 
			   WHEN UOM = 'UnitPrice' THEN 
			   CONVERT(DECIMAL (18,2),Value)
			   ELSE
			   '0'
			   END AS UnitPrice 
			 , CASE 
			   WHEN UOM = 'shrinkPrice' THEN 
				CONVERT(DECIMAL (18,2),Value) 
				ELSE
			   '0'
			   END AS shrinkPrice 
			 , CASE 
			   WHEN UOM = 'Promo' THEN 
			   LOWER(LEFT(Value ,1))
				ELSE
			   'n'
			   END AS Promo
		FROM #pS1
		) AS t 

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
------Part 3  Update UOM where item was on Promo
	UPDATE a 
	SET promo = b.promo
	FROM #pS2 a
	CROSS APPLY (SELECT (CHARINDEX('_', a.item))) AS P1(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P1.Pos+1))) AS P2(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P2.Pos+1))) AS P3(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P3.Pos+1))) AS P4(Pos)
	INNER JOIN #pS2 b 
	ON a. taskInstanceUuid = b.taskInstanceUuid
	AND SUBSTRING(a.item, 1, P4.pos-1) = SUBSTRING(b.item, 1, P4.pos-1)
	WHERE (a.UnitPrice <> '0.00' OR a.shrinkPrice <> '0.00' ) --Should update all values = 0 when a promo has been selected
	AND b.promo = 'y'
 --//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--Part 4 delete promo item with zero values
	DELETE #pS2
	FROM #pS2
	WHERE item LIKE '%_Promo'
 --///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 --Part 5 Get distinct list of item variations per taskinstanceuuid
	SELECT DISTINCT  a.taskInstanceUuid,a.pdfuuid,SUBSTRING(a.item, 1, P4.pos-1)AS Item, CONVERT(DECIMAL(18,2),0.00)AS unitPrice, CONVERT(DECIMAL(18,2),0.00)AS shrinkPrice, 'n' AS promo
	INTO  #pS3
	FROM #pS2 a
	CROSS APPLY (SELECT (CHARINDEX('_', a.item))) AS P1(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P1.Pos+1))) AS P2(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P2.Pos+1))) AS P3(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P3.Pos+1))) AS P4(Pos)
--/////////////////////////////////////////////////////////////////////////////
 --Part 6 Get all item variations per taskinstanceuuid to update the above list 
	SELECT a.*,SUBSTRING(a.item, 1, P4.pos-1) AS Code 
	INTO #pS4
	FROM #pS2 a
	CROSS APPLY (SELECT (CHARINDEX('_', a.item))) AS P1(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P1.Pos+1))) AS P2(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P2.Pos+1))) AS P3(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P3.Pos+1))) AS P4(Pos)
--/////////////////////////////////////////////////////////////////////////
--Part 7
--Update unitprice
	UPDATE a 
	SET unitPrice = b.unitPrice
	FROM #pS3 a
	INNER JOIN #pS4 b
	ON a.taskInstanceUuid=b.taskInstanceUuid
	AND a.Item = b.Code
	WHERE b.UnitPrice <> 0.00
--Update shrinkprice
	UPDATE a 
	SET a.shrinkPrice = b.shrinkPrice
	FROM #pS3 a
	INNER JOIN #pS4 b
	ON a.taskInstanceUuid=b.taskInstanceUuid
	AND a.Item = b.Code
	WHERE b.shrinkPrice <> 0.00
--Update Promo
	UPDATE a 
	SET a.promo = b.promo
	FROM #pS3 a
	INNER JOIN #pS4 b
	ON a.taskInstanceUuid=b.taskInstanceUuid
	AND a.Item = b.Code
	WHERE b.Promo <>'n'
 --//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 --insert values from #pS3 and defaults taskTracker values 
 INSERT INTO  st_priceSurvey
 ( Domain,taskInstanceUuid,pdFUuid,keyprodCategory,KeyCustomer,appointmentTypeUuid,keyscheduleType,keyappointmentDate,keystartTime,keyendTime,companyUserUuid,customerLocationUuid
,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,keytaskStatus,keycompletedDate,keycompletedTime,taskTypeUuid,currency,Item
,unitPrice,shrinkPrice,promo)
 SELECT  '' AS Domain, taskInstanceUuid,pdFUuid,-1 AS keyprodCategory,-1 AS KeyCustomer,'' AS appointmentTypeUuid,-1 AS keyscheduleType,-1 AS keyappointmentDate
		,-1 AS keystartTime,-1 AS keyendTime,'' AS companyUserUuid,'' AS customerLocationUuid,'' AS customerAccountUuid,''AS tradeChannelUuid,'' AS principalUuid,'' AS serviceProviderUuid
		,'' AS salesAgencyCostCentreUuid,-1 AS keytaskStatus,-1 AS keycompletedDate,-1 AS keycompletedTime,''AS taskTypeUuid, 'zar' AS currency,Item,unitPrice, shrinkPrice, promo	
FROM #pS3
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--update taskTracker values
	UPDATE st_priceSurvey
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
	FROM st_priceSurvey a 
	INNER JOIN Warehouse_BlueFileData.Fact.taskTracker b
	ON a.taskInstanceUuid = b.taskInstanceUuid

/**************************************
***	NB: update currency from  pdfdata *
**************************************/

--/////////////////////////////////////////////////////////////////////////
--Update  keyprodCategory
	UPDATE st_priceSurvey
	SET keyprodCategory = b.keyprodCategory
	FROM st_priceSurvey a 
	INNER JOIN Warehouse_BlueFileData.[Dimension].[priceSurveyProdCategory] b
	ON a.item  = (b.domain +'_'+ b.principal +'_'+ b.pLine +'_'+ b.packSize)

--///////////////////////////////////////////////////////////////////////////
-- Align the old price survey to the new version

--Insert unitpriceReg
	SELECT taskInstanceUuid,Item,
		  CASE
		  WHEN  (a.unitprice <> 0 and a.promo ='n') THEN
			 CASE
			 WHEN  (a.unitprice > (CONVERT(DECIMAL (18,2),b.unitpriceReg ) * 0.7)) AND (a.unitprice < ((CONVERT(DECIMAL (18,2),b.unitpriceReg ) * 1.3))) THEN
				  'y'
			 ELSE
				  'n'
			 END
		 END AS acceptUnitPrice INTO #unitprice
	FROM [Staging_BlueFileData].[dbo].[st_priceSurvey] a
	INNER JOIN umt_priceSurvey_Fix b
	ON a.Item = b.FieldName
--Update unitpriceReg
	UPDATE [st_priceSurvey]
	SET acceptUnitPrice = b.acceptUnitPrice
	FROM [st_priceSurvey] a
	INNER JOIN #unitprice b
	ON a.taskinstanceuuid = b.taskinstanceuuid 
	AND  a.item =b.item
	WHERE b.acceptUnitPrice IS NOT NULL

--unitpricePromo
	SELECT taskInstanceUuid,Item,
		  CASE
		  WHEN  (a.unitprice <> 0 and a.promo ='y') THEN
			 CASE
			 WHEN  (a.unitprice > (CONVERT(DECIMAL (18,2),b.unitpricePromo ) * 0.7)) AND (a.unitprice < ((CONVERT(DECIMAL (18,2),b.unitpricePromo ) * 1.3))) THEN
				  'y'
			 ELSE
				  'n'
			 END
		 END AS acceptUnitPrice INTO #unitpricePromo
	FROM [Staging_BlueFileData].[dbo].[st_priceSurvey] a
	INNER JOIN umt_priceSurvey_Fix b
	ON a.Item = b.FieldName

--Update #unitpricePromo
	UPDATE [st_priceSurvey]
	SET acceptUnitPrice = b.acceptUnitPrice
	FROM [st_priceSurvey] a
	INNER JOIN #unitpricePromo b
	ON a.taskinstanceuuid = b.taskinstanceuuid 
	AND  a.item =b.item
	WHERE b.acceptUnitPrice IS NOT NULL


--shrinkpriceReg
	SELECT taskInstanceUuid,Item,
		  CASE
		  WHEN  (a.shrinkprice <> 0 and a.promo ='n') THEN
			 CASE
			 WHEN  (a.shrinkprice > (CONVERT(DECIMAL (18,2),b.shrinkpriceReg ) * 0.7)) AND (a.shrinkprice < ((CONVERT(DECIMAL (18,2),b.shrinkpriceReg ) * 1.3))) THEN
				  'y'
			  ELSE
				  'n'
			 END
		 END AS acceptShrinkPrice INTO #shrinkpriceReg
	FROM [Staging_BlueFileData].[dbo].[st_priceSurvey] a
	INNER JOIN umt_priceSurvey_Fix b
	ON a.Item = b.FieldName

--Update #shrinkpriceReg
	UPDATE [st_priceSurvey]
	SET acceptShrinkPrice = b.acceptShrinkPrice
	FROM [st_priceSurvey] a
	INNER JOIN #shrinkpriceReg b
	ON a.taskinstanceuuid = b.taskinstanceuuid 
	AND  a.item =b.item
	WHERE b.acceptShrinkPrice IS NOT NULL

--shrinkpricePromo
	SELECT taskInstanceUuid,Item,
		  CASE
		  WHEN  (a.shrinkprice <> 0 and a.promo ='y') THEN
			 CASE
			 WHEN  (a.shrinkprice > (CONVERT(DECIMAL (18,2),b.shrinkpricePromo ) * 0.7)) AND (a.shrinkprice < ((CONVERT(DECIMAL (18,2),b.shrinkpricePromo ) * 1.3))) THEN
				  'y'
			  ELSE
				  'n'
			 END
		 END AS acceptShrinkPrice INTO #shrinkpricePromo
	FROM [Staging_BlueFileData].[dbo].[st_priceSurvey] a
	INNER JOIN umt_priceSurvey_Fix b
	ON a.Item = b.FieldName 

--Update #shrinkpricePromo
	UPDATE [st_priceSurvey]
	SET acceptShrinkPrice = b.acceptShrinkPrice
	FROM [st_priceSurvey] a
	INNER JOIN #ShrinkpricePromo b
	ON a.taskinstanceuuid = b.taskinstanceuuid 
	AND  a.item =b.item
	WHERE b.acceptShrinkPrice IS NOT NULL

--==================================================================
--Overwrite existing priceSurvey records
--==================================================================
	DELETE [Warehouse_BlueFileData].[Fact].[priceSurvey]
	FROM [Warehouse_BlueFileData].[Fact].[priceSurvey] a
	INNER JOIN st_priceSurvey b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	AND  a.Domain = b.Domain
	WHERE a.KeytaskStatus <> 2
--===================================================================
--Insert new records into Fact.priceSurvey
--===================================================================

	INSERT INTO Warehouse_BlueFileData.Fact.priceSurvey
	( Domain,taskInstanceUuid,pdFUuid,keyprodCategory,KeyCustomer,appointmentTypeUuid,keyscheduleType,keyappointmentDate,keystartTime,keyendTime,companyUserUuid,customerLocationUuid
	,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,keytaskStatus,keycompletedDate,keycompletedTime,taskTypeUuid,currency,price,promo,priceType)

	SELECT  Domain,taskInstanceUuid,pdFUuid,keyprodCategory,KeyCustomer,appointmentTypeUuid,keyscheduleType,keyappointmentDate,keystartTime,keyendTime,companyUserUuid,customerLocationUuid
			,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,keytaskStatus,keycompletedDate,keycompletedTime,taskTypeUuid,currency,0,promo,''
	FROM st_priceSurvey
	WHERE (acceptUnitPrice = 'y'  OR  acceptShrinkPrice = 'y')

--Update Price with shrinkPrice as it takes precedence
	UPDATE Warehouse_BlueFileData.Fact.priceSurvey
	SET price = b.shrinkPrice,
		priceType = 'shrink'
	FROM Warehouse_BlueFileData.Fact.priceSurvey a
	INNER JOIN st_priceSurvey b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	AND a.keyprodCategory = b.keyprodCategory
	WHERE b.acceptshrinkPrice = 'y' 

--Update Price with unitPrice 
	UPDATE Warehouse_BlueFileData.Fact.priceSurvey
	SET price = b.unitPrice,
		priceType = 'unit'
	FROM Warehouse_BlueFileData.Fact.priceSurvey a
	INNER JOIN st_priceSurvey b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	AND a.keyprodCategory = b.keyprodCategory
	WHERE b.acceptshrinkPrice <> 'y' 
	AND b.acceptunitPrice ='y'


--==================================================================
--Redirect Failed records
--Overwrite existing failed priceSurvey records
--==================================================================
	DELETE st_priceSurveyFailedRecords
	FROM st_priceSurveyFailedRecords a
	INNER JOIN st_priceSurvey b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	AND  a.Domain = b.Domain
	AND a.keyprodCategory = b.keyprodCategory
	WHERE a.KeytaskStatus <> 2

--==================================================================
--Redirect Failed records
--Insert new failed priceSurvey records
--==================================================================
	INSERT INTO st_priceSurveyFailedRecords
	( Domain,taskInstanceUuid,pdFUuid,keyprodCategory,KeyCustomer,appointmentTypeUuid,keyscheduleType,keyappointmentDate,keystartTime,keyendTime,companyUserUuid,customerLocationUuid
	,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,keytaskStatus,keycompletedDate,keycompletedTime,taskTypeUuid,currency,unitPrice,shrinkPrice,promo,acceptUnitPrice,acceptShrinkPrice)
	 SELECT  Domain,taskInstanceUuid,pdFUuid,keyprodCategory,KeyCustomer,appointmentTypeUuid,keyscheduleType,keyappointmentDate,keystartTime,keyendTime,companyUserUuid,customerLocationUuid
			,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,keytaskStatus,keycompletedDate,keycompletedTime,taskTypeUuid,currency,unitPrice,shrinkPrice,promo,acceptUnitPrice,acceptShrinkPrice
	FROM st_priceSurvey
	WHERE ((acceptUnitPrice = 'n'  AND  acceptShrinkPrice = 'n')
	OR   (acceptUnitPrice = ''  AND  acceptShrinkPrice = '')
	OR   (acceptUnitPrice = 'n'  AND  acceptShrinkPrice = '')
	OR   (acceptUnitPrice = ''  AND  acceptShrinkPrice = 'n'))
	
END
  
