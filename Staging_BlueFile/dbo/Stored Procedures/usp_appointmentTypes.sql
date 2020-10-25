
-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Load appointmentTyes>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_appointmentTypes]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_appointmentTypes

	INSERT INTO st_appointmentTypes
	(appointmentTypeuuid ,status, name, tasksRequired,loadDate)
	SELECT uuid ,status, name, tasksRequired, GETDATE()
	FROM appointmentTypes
--===================================================================
--Delete appointmentTypesInstance from appointmentTypes 
--===================================================================
	DELETE appointmentTypes
	FROM appointmentTypes a
	INNER JOIN st_appointmentTypes b
	ON a.uuid = b.appointmentTypeUuid
--===============================================================
--Overwrite existing appointmentTypes records
--==============================================================
	DELETE [Warehouse_BlueFileData].[Dimension].[appointmentTypes]
	FROM [Warehouse_BlueFileData].[Dimension].[appointmentTypes] a
	INNER JOIN st_appointmentTypes b
	ON a.appointmentTypeUuid = b.appointmentTypeUuid

--===================================================================
--Insert new appointmentTypes records
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Dimension].[appointmentTypes]
	(appointmentTypeuuid ,status, name, tasksRequired,refreshDate)
	SELECT appointmentTypeUuid ,status, name, tasksRequired, GETDATE()
	FROM st_appointmentTypes
--==================================================================
-- Insert new appointmentTypes records from taskTracker
--==================================================================
	/*INSERT INTO [Warehouse_BlueFileData].[Dimension].[appointmentTypes]
	(appointmentTypeUuid ,status, name, tasksRequired,refreshDate)
	SELECT CASE
			  WHEN (a.appointmentTypeUuid IS NULL) THEN
					'-1'
			  ELSE
			  a.appointmentTypeUuid
			  END AS appointmentTypeUuid, 'unknowm' AS status, 'unknowm' AS name,'unknowm' AS tasksRequired ,GETDATE()
	FROM taskTracker a
	LEFT JOIN [Warehouse_BlueFileData].[Dimension].[appointmentTypes] b
	ON a.appointmentTypeUuid = b.appointmentTypeUuid
	WHERE b.appointmentTypeUuid IS NULL*/

END
