

-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-10-22>
-- Description:	<Load purgeLogData>
-- Delete old revords from the log table and only 
-- keep records that for the current month
-- ==================================================
CREATE PROCEDURE [dbo].[usp_purgeLogData]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
	DELETE [rabbitmqMessageLog]
	FROM [rabbitmqMessageLog]
	WHERE YEAR(LoadDate) = Year(GETDATE())
	AND MONTH(LoadDate) < MONTH(GETDATE())
	AND DAY(GETDATE()) > '15'
END
