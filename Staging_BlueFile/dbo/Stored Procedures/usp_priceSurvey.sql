

-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Load usp_priceSurveyData>
-- Price Survey processed where value <> 0 or blank (unitprice, shrinkprice and bulkbuyunits)
-- and BulkBuy and Promo have been selected
-- ==================================================
CREATE PROCEDURE [dbo].[usp_priceSurvey]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_priceSurvey
	SELECT taskInstanceUuid,uuid AS pdFUuid,name AS Item,SUBSTRING(name, P4.Pos + 1, LEN(name)) AS UOM, value 
	INTO  #pS1
	FROM pdFData
	CROSS APPLY (SELECT (CHARINDEX('_', name))) AS P1(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P1.Pos+1))) AS P2(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P2.Pos+1))) AS P3(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P3.Pos+1))) AS P4(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', name, P4.Pos+1))) AS P5(Pos)
	WHERE (name   like '%_unitprice' OR name like '%_shrinkprice' OR name like '%_Promo' OR name like '%_BulkBuy%'  ) 
	AND value <> 'new product'
	AND subject ='price survey'
	AND value not in ('0','','off','.')
---/////////////////////////////////////////////////////////////////////////////////////////////////////////////
--Part 2 transpose values to UOM
	SELECT taskInstanceUuid,pdfUuid,item, unitPrice,shrinkPrice,promo,bulkBuy,bulkBuyUnits INTO #pS2
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
			   ENd AS Promo
			   --- consider removing  code below or not bringing it to the fact table this pending the BI/BF workshop
			 , CASE 
			   WHEn UOM = 'BulkBuy' THEN 
				LOWER(LEFT(Value,1))
				ELSE
			   'n'
			   END AS BulkBuy  
			   -----------------------------------------------------------------------------------------
			 , CASE 
			   WHEn UOM = 'BulkBuyUnits' THEN 
			   CONVERT(DECIMAL (18,2),Value)
				ELSE
			   '0'
			   END AS BulkBuyUnits    
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
	WHERE (a.UnitPrice <> '0.00' OR a.shrinkPrice <> '0.00' OR a.BulkBuyUnits <> '0.00') --Should update all values = 0 when a promo has been selected
	AND b.promo = 'y'
 --//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--Part 4 delete promo item with zero values
	DELETE #pS2
	FROM #pS2
	WHERE item LIKE '%_Promo'
 --///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Part 4 Update UOM where item was a BulkBuy - consider removing or not bringing it to the fact table this pending the BI/BF workshop
	UPDATE a 
	SET bulkBuy = b.bulkBuy
	FROM #pS2 a
	CROSS APPLY (SELECT (CHARINDEX('_', a.item))) AS P1(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P1.Pos+1))) AS P2(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P2.Pos+1))) AS P3(Pos)
	CROSS APPLY (SELECT (CHARINDEX('_', a.item, P3.Pos+1))) AS P4(Pos)
	INNER JOIN #pS2 b 
	ON a. taskInstanceUuid = b.taskInstanceUuid
	AND SUBSTRING(a.item, 1, P4.pos-1) = SUBSTRING(b.item, 1, P4.pos-1)
	WHERE a.BulkBuyUnits =  '0.00'
	AND a.BulkBuy = 'n'
	AND b.BulkBuy = 'y'
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	DELETE #pS2
	FROM #pS2
	WHERE item like '%BulkBuy'
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 --Part 5 Get distinct list of item variations per taskinstanceuuid
	SELECT DISTINCT  a.taskInstanceUuid,a.pdfuuid,SUBSTRING(a.item, 1, P4.pos-1)AS Item, CONVERT(DECIMAL(18,2),0.00)AS unitPrice, CONVERT(DECIMAL(18,2),0.00)AS shrinkPrice, 'n' AS promo, 'n' AS bulkBuy, CONVERT(DECIMAL(18,2),0.00)  AS bulkBuyUnits 
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
	--Update BulkBuy
	--consider removing or not bringing it to the fact table this pending the BI/BF workshop
	UPDATE a 
	SET a.bulkBuy = b.bulkBuy
	FROM #pS3 a
	INNER JOIN #pS4 b
	ON a.taskInstanceUuid=b.taskInstanceUuid
	AND a.Item = b.Code
	WHERE b.BulkBuy <>'n'
	--Update BulkBuyUnits
	UPDATE a 
	SET a.BulkBuyUnits = b.BulkBuyUnits
	FROM #pS3 a
	INNER JOIN #pS4 b
	ON a.taskInstanceUuid=b.taskInstanceUuid
	AND a.Item = b.Code
	WHERE b.BulkBuyUnits <>0.00
 --//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 --insert values from #pS3 and defaults taskTracker values 
 INSERT INTO  st_priceSurvey
 SELECT  '' AS Domain, taskInstanceUuid,pdFUuid,-1 AS keyproductCatgory,-1 AS keyDocType,-1AS KeyCustomer,'' AS appointmentTypeUuid,-1 AS keyscheduleType,-1 AS keyappointmentDate
		,-1 AS keystartTime,-1 AS keyendTime,'' AS companyUserUuid,'' AS customerLocationUuid,'' AS customerAccountUuid,''AS tradeChannelUuid,'' AS principalUuid,'' AS serviceProviderUuid
		,'' AS salesAgencyCostCentreUuid,-1 AS keytaskStatus,-1 AS keycompletedDate,-1 AS keycompletedTime,''AS taskTypeUuid, 'zar' AS currency,Item,unitPrice, shrinkPrice, promo
		,bulkBuy,bulkBuyUnits,'n' AS competitor				
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
END
