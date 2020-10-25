CREATE TABLE [dbo].[customerAccount] (
    [uuid]                 VARCHAR (100) NULL,
    [number]               VARCHAR (100) NULL,
    [tradeChannelNodeUuid] VARCHAR (100) NULL,
    [customerLocationUuid] VARCHAR (100) NULL,
    [channelUuid]          VARCHAR (100) NULL,
    [brandTypeUuid]        VARCHAR (100) NULL,
    [description]          VARCHAR (100) NULL,
    [status]               VARCHAR (100) NULL,
    [type]                 VARCHAR (100) NULL,
    [loadDate]             DATETIME      NOT NULL
);


GO


-- =============================================
-- Author:		Sanele Ndlela
-- Create date: 2020-07-28
-- Description:	After a record has been inserted
--				the trigger gets fired to execute
--				usp_customerAccount info to be inserted
--				in the customerAccount table  
-- =============================================
CREATE TRIGGER [dbo].[trgInsert_customerAccount]     
ON [dbo].[customerAccount]
AFTER INSERT
AS  BEGIN
    SET NOCOUNT ON;
	--/////////////////////////////
    EXEC dbo.usp_customerAccount
END
