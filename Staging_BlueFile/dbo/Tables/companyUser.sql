CREATE TABLE [dbo].[companyUser] (
    [uuid]                  VARCHAR (100) NULL,
    [status]                VARCHAR (10)  NULL,
    [contractedHours]       INT           NULL,
    [effectiveFromDate]     DATETIME      NULL,
    [effectiveToDate]       DATETIME      NULL,
    [userUuid]              VARCHAR (100) NULL,
    [companyUuid]           VARCHAR (100) NULL,
    [accessLevels]          VARCHAR (100) NULL,
    [username]              VARCHAR (100) NULL,
    [firstName]             VARCHAR (100) NULL,
    [lastName]              VARCHAR (100) NULL,
    [emailAddress]          VARCHAR (100) NULL,
    [identityNumber]        VARCHAR (50)  NULL,
    [passportNumber]        VARCHAR (100) NULL,
    [admin]                 VARCHAR (100) NULL,
    [availableForSelection] VARCHAR (100) NULL,
    [reason]                VARCHAR (500) NULL,
    [type]                  VARCHAR (100) NULL,
    [loadDate]              DATETIME      NULL
);


GO


-- =============================================
-- Author:		Sanele Ndlela
-- Create date: 2020-07-28
-- Description:	After a record has been inserted
--				the trigger gets fired to execute
--				usp_companyUser info to be inserted
--				in the companyUser table  
-- =============================================
CREATE TRIGGER [dbo].[trgInsert_companyUser]     
ON [dbo].[companyUser]  
AFTER INSERT
AS  BEGIN
    SET NOCOUNT ON;
	--/////////////////////////////
    EXEC dbo.usp_companyUser
END
