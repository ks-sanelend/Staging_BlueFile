



-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Load customerLocation>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_customerLocation]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_customerLocation

	INSERT INTO st_customerLocation
	(customerLocationUuid,tradeEntityUuid,locationUuid,description,deliveryLocationUuid,status,type,loadDate)
	SELECT uuid ,CASE
				 WHEN (tradeEntityUuid IS NULL) THEN
						'-1'
				 ELSE
						tradeEntityUuid
				 END AS tradeEntityUuid,
				 CASE 
				 WHEN (locationUuid IS NULL) THEN
						'-1'
				 ELSE
						locationUuid
				 END AS locationUuid, description,
				 CASE 
				 WHEN (deliveryLocationUuid IS NULL) THEN
						'-1'
				 ELSE
						deliveryLocationUuid
				 END AS deliveryLocationUuid, status, type, GETDATE()
	FROM customerLocation
--===================================================================
--Delete customerLocationInstance from customerLocation 
--===================================================================
	DELETE customerLocation
	FROM customerLocation a
	INNER JOIN st_customerLocation b
	ON a.uuid = b.customerLocationUuid
--===============================================================
--Overwrite existing customerLocation records
--==============================================================
	DELETE [Warehouse_BlueFileData].[Dimension].[customerLocation]
	FROM [Warehouse_BlueFileData].[Dimension].[customerLocation] a
	INNER JOIN st_customerLocation b
	ON a.customerLocationUuid = b.customerLocationUuid
--===================================================================
--Insert new customerLocation records
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Dimension].[customerLocation]
	(customerLocationUuid,tradeEntityUuid,locationUuid,description,deliveryLocationUuid,status,type, refreshDate)
	SELECT customerLocationUuid,tradeEntityUuid,locationUuid,description,deliveryLocationUuid,status,type, GETDATE()
	FROM st_customerLocation
END
