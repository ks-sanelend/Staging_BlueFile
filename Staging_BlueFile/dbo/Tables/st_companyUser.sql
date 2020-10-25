CREATE TABLE [dbo].[st_companyUser] (
    [companyUserUuid]       VARCHAR (100) NOT NULL,
    [status]                VARCHAR (10)  NULL,
    [contractedHours]       INT           NULL,
    [effectiveFromDate]     DATETIME      NULL,
    [effectiveToDate]       DATETIME      NULL,
    [userUuid]              VARCHAR (100) NOT NULL,
    [companyUuid]           VARCHAR (100) NOT NULL,
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

