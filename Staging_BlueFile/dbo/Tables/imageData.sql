CREATE TABLE [dbo].[imageData] (
    [taskInstanceUuid] VARCHAR (100) NULL,
    [uuid]             VARCHAR (100) NULL,
    [created]          VARCHAR (100) NULL,
    [batch]            VARCHAR (100) NULL,
    [reference]        VARCHAR (100) NULL,
    [uri]              VARCHAR (500) NULL,
    [store]            VARCHAR (100) NULL,
    [height]           INT           NULL,
    [width]            INT           NULL,
    [loadDate]         DATETIME      NULL
);


GO

-- =============================================
-- Author:		Sanele Ndlela
-- Create date: 2020-08-25
-- Description:	After a record has been inserted
--				the trigger gets fired to execute
--				usp_imageData info to be inserted
--				in the imageData table  
-- =============================================
CREATE TRIGGER [dbo].[trgInsert_imageData]     
ON [dbo].[imageData]  
AFTER INSERT
AS  BEGIN
    SET NOCOUNT ON;
	--/////////////////////////////
    EXEC dbo.usp_imageData
END
