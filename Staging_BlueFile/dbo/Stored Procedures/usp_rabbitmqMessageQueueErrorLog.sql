

-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Log Error messages from .NET app>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_rabbitmqMessageQueueErrorLog]
	@rabbitmq_Msg nvarchar (max), @routing_Key nvarchar (100), @ex_Message nvarchar (1000)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	INSERT INTO rabbitmqMessageLog
	SELECT @rabbitmq_Msg, @routing_Key, @ex_Message,GETDATE()
END
