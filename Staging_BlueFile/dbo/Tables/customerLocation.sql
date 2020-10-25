CREATE TABLE [dbo].[customerLocation] (
    [uuid]                 VARCHAR (100) NULL,
    [tradeEntityUuid]      VARCHAR (100) NULL,
    [locationUuid]         VARCHAR (100) NULL,
    [description]          VARCHAR (100) NULL,
    [deliveryLocationUuid] VARCHAR (100) NULL,
    [status]               VARCHAR (100) NULL,
    [type]                 VARCHAR (100) NULL,
    [loadDate]             DATETIME      NULL
);


GO


-- =============================================
-- Author:		Sanele Ndlela
-- Create date: 2020-07-28
-- Description:	After a record has been inserted
--				the trigger gets fired to execute
--				usp_customerLocation info to be inserted
--				in the customerLocation table  
-- =============================================
CREATE TRIGGER [dbo].[trgInsert_customerLocation]     
ON [dbo].[customerLocation]  
AFTER INSERT
AS  BEGIN
    SET NOCOUNT ON;
	--/////////////////////////////
    EXEC dbo.usp_customerLocation
END
