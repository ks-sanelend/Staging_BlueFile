﻿CREATE TABLE [dbo].[st_merchandisingSurvey] (
    [Domain]                    VARCHAR (8)   NULL,
    [taskInstanceUuid]          VARCHAR (100) NULL,
    [pdFUuid]                   VARCHAR (100) NULL,
    [keyCustomer]               INT           NULL,
    [appointmentTypeUuid]       VARCHAR (100) NULL,
    [keyscheduleType]           INT           NULL,
    [keyappointmentDate]        INT           NULL,
    [keystartTime]              INT           NULL,
    [keyendTime]                INT           NULL,
    [companyUserUuid]           VARCHAR (100) NULL,
    [customerLocationUuid]      VARCHAR (100) NULL,
    [customerAccountUuid]       VARCHAR (100) NULL,
    [tradeChannelUuid]          VARCHAR (100) NULL,
    [principalUuid]             VARCHAR (100) NULL,
    [serviceProviderUuid]       VARCHAR (100) NULL,
    [salesAgencyCostCentreUuid] VARCHAR (100) NULL,
    [keytaskStatus]             INT           NULL,
    [keycompletedDate]          INT           NULL,
    [keycompletedTime]          INT           NULL,
    [taskTypeUuid]              VARCHAR (100) NULL,
    [keyProduct]                INT           NULL,
    [Item]                      VARCHAR (100) NULL,
    [pLine]                     VARCHAR (4)   NULL,
    [packSize]                  VARCHAR (30)  NULL,
    [productPlacement]          VARCHAR (50)  NULL,
    [shelfFacings]              VARCHAR (10)  NULL,
    [2ndDisplayType]            VARCHAR (50)  NULL
);

