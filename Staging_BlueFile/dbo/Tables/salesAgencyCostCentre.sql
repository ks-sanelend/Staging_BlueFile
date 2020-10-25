CREATE TABLE [dbo].[salesAgencyCostCentre] (
    [salesAgencyCostCentreUuid]         VARCHAR (100) NULL,
    [code]                              VARCHAR (100) NULL,
    [name]                              VARCHAR (100) NULL,
    [description]                       VARCHAR (100) NULL,
    [companyUuid]                       VARCHAR (100) NULL,
    [startDate]                         DATETIME      NULL,
    [endDate]                           DATETIME      NULL,
    [status]                            VARCHAR (100) NULL,
    [currentCustodianFirstName]         VARCHAR (100) NULL,
    [currentCustodianLastName]          VARCHAR (100) NULL,
    [currentCustodianUuid]              VARCHAR (100) NULL,
    [detailedDescription]               VARCHAR (100) NULL,
    [reason]                            VARCHAR (100) NULL,
    [omsMappingValidationMessage]       VARCHAR (100) NULL,
    [custodianLinkEndDate]              DATETIME      NULL,
    [costCentreCustodianLinksUuid]      VARCHAR (100) NULL,
    [companyUserUuid]                   VARCHAR (100) NULL,
    [costCentreCustodianLinksStatus]    VARCHAR (10)  NULL,
    [contractedHours]                   INT           NULL,
    [effectiveFromDate]                 DATETIME      NULL,
    [effectiveToDate]                   DATETIME      NULL,
    [userUuid]                          VARCHAR (100) NULL,
    [username]                          VARCHAR (100) NULL,
    [firstName]                         VARCHAR (100) NULL,
    [lastName]                          VARCHAR (100) NULL,
    [emailAddress]                      VARCHAR (100) NULL,
    [identityNumber]                    BIGINT        NULL,
    [admin]                             VARCHAR (100) NULL,
    [availableForSelection]             VARCHAR (100) NULL,
    [costCentreCustodianLinksReason]    VARCHAR (100) NULL,
    [costCentreCustodianLinksStartDate] DATETIME      NULL,
    [costCentreCustodianLinksEndDate]   DATETIME      NULL,
    [loadDate]                          DATETIME      NULL
);


GO


-- =============================================
-- Author:		Sanele Ndlela
-- Create date: 2020-07-28
-- Description:	After a record has been inserted
--				the trigger gets fired to execute
--				usp_salesAgencyCostCentre info to be inserted
--				in the salesAgencyCostCentre table  
-- =============================================
CREATE TRIGGER [dbo].[trgInsert_salesAgencyCostCentre]     
ON [dbo].[salesAgencyCostCentre]  
AFTER INSERT
AS  BEGIN
    SET NOCOUNT ON;
	--/////////////////////////////
    EXEC dbo.usp_salesAgencyCostCentre
END
